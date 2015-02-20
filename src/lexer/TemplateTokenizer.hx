package lexer;

class TemplateTokenizer implements ITokenizer {
    public var stringReader:StringReader;
    public var string:String;

    public function new(string:String) {
        this.string = string;
        this.stringReader = new StringReader(this.string);
    }

    public function hasMore():Bool {
        return this.stringReader.hasMore();
    }

    /**
	 * Return a list of tokens.
	 *
	 * @return list of tokenized tokens.
	 */
    public function tokenizeAll():Array<Token> {
        var tokens = [];
        while (this.hasMore()) {
            var token = this.readNext();
//console.log(token);
            if (token == null) break;
            tokens.push(token);
        }
        return tokens;
    }

    public var tokens = [];
    public var regExp = ~/\{[\{%#]-?/;
    public var stringOffsetStart = 0;
    public var stringOffsetEnd = 0;
    public var openMatch:MatchResult;
    public var openChars3:String;
    public var openChars:String;
    public var removeSpacesBefore:Bool;
    public var removeSpacesAfter:Bool;
    public var state = 0;

    private function emitToken(type, ?value, ?params) {
        if (type == 'text' && value == '') return null;

        this.stringOffsetEnd = this.stringReader.getOffset();

        var token = new Token(
            type,
            value,
            this.stringReader.getSlice(this.stringOffsetStart, this.stringOffsetEnd),
            this.stringOffsetStart,
            this.stringOffsetEnd,
            params
        );

        this.stringOffsetStart = this.stringOffsetEnd;

        return token;
    }

    public function readNext():Token {
        var token:Token = null;
        while (true) {
            if (token != null) return token;
            switch (this.state) {
                case 0:
                    if (!this.stringReader.hasMore()) return null;

                    this.stringOffsetStart = this.stringReader.getOffset();

                    this.openMatch = this.stringReader.findRegexp(this.regExp);
// No more tags.
                    if (!this.openMatch.matched) {
                        this.state = 0;
                        token = this.emitToken('text', this.stringReader.readLeft());
                    }
// At least one more tag.
                    else {
                        this.state = 1;
                        token = this.emitToken('text', this.stringReader.readChars(this.openMatch.position));
                    }
                case 1:
                    this.openChars3 = this.stringReader.readChars(this.openMatch.length);
                    this.openChars = this.openChars3.substr(0, 2);
                    this.removeSpacesBefore = (this.openChars3.substr(2, 1) == '-');
                    this.removeSpacesAfter = null;

                    this.state = 2;
                    if (this.removeSpacesBefore) token = this.emitToken('trimSpacesBefore');
                case 2:
                    this.state = 3;
//if (openChars.length == 3)
                    switch (this.openChars) {
// A comment.
                        case '{#':
                            var closeMatch = this.stringReader.findRegexp(~/\-?#} /);
                            if (!closeMatch.matched) throw "Comment not closed!";
                            this.stringReader.skipChars(closeMatch.position + closeMatch.length);
                            this.removeSpacesAfter = (closeMatch.length == 3);
                        case '{{', '{%':
                            var expressionTokenizer = new ExpressionTokenizer.ExpressionTokenizer(new StringReader(
                                this.stringReader.getSliceWithCallback(function() {
                                    (new ExpressionTokenizer.ExpressionTokenizer(this.stringReader)).tokenizeAll();
                                })
                            ));
                            
                            var peekMinus = this.stringReader.peekChars(1);
                            if (peekMinus == '-') this.stringReader.skipChars(1);
                            this.removeSpacesAfter = (peekMinus == '-');
                            var closeChars = this.stringReader.readChars(2);
                            
                            if (
                                (this.openChars == '{{' && closeChars != '}}') ||
                                (this.openChars == '{%' && closeChars != '%}')
                            ) {
                                throw 'Open type was "' + this.openChars + '" but close type was "' + closeChars + '"';
                            }
                            
                            if (this.openChars == '{{') {
                                token = this.emitToken('expression', expressionTokenizer);
                            } else {
                                token = this.emitToken('block', expressionTokenizer);
                            }
                        default:
                            throw 'Unknown open type "' + this.openChars + '"!';
                    }
                case 3:
                    if (this.removeSpacesAfter) token = this.emitToken('trimSpacesAfter');
                    this.state = 0;
                default:
                    throw "Invalid state";
            }
        }

        return null;
    }
}
