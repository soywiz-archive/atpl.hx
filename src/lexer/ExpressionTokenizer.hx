package lexer;
/**
 * ExpressionTokenizer
 */
import runtime.RuntimeUtils2;
import haxe.Json;

class ExpressionTokenizer implements ITokenizer {
    public var stringReader: StringReader;

    /**
	 * Creates a new ExpressionTokenizer.
	 */
    public function new(stringReader: StringReader) {
        this.stringReader = stringReader;
    }

    private static var operators3 = [
        '===', '!=='
    ];

    private static var operators2 = [
        '++', '--', '&&', '||', '..', '//', '**',
        '==', '>=', '<=', '!=', '?:'
    ];

    private static var operators1 = [
        '+', '-', '*', '/', '%', '|', '(', ')',
        '{', '}', '[', ']', '.', ':', ',', '<', '>', '?', '=', '~'
    ];

    //static tokenizeString(string: string) {
    //	return tokenizeStringReader(new StringReader.StringReader(string));
    //}
    //
    //static tokenizeStringReader(stringReader: StringReader.StringReader) {
    //	return new ExpressionTokenizer(stringReader).tokenizeAll();
    //}
    
    /**
	 * Return a list of tokens.
	 *
	 * @return list of tokenized tokens.
	 */
    public function tokenizeAll(): Array<Token> {
        var tokens = [];
        while (this.hasMore()) {
            var token = this.readNext();
            
            if (token.type == 'eof') break;
            
            //console.log(token);
            //if (token == null) break;
            tokens.push(token);
        }
        return tokens;
    }

    private var eof = false;

    /**
	 *
	 */
    public function hasMore(): Bool {
        if (this.end) return false;
        return this.stringReader.hasMore() && (this.stringReader.findRegexp(~/^(\s*$|\-?[%\}]\})/).noMatchesAtStart());
    }

    public var end = false;
    public var stringOffset: Int = 0;

    private function emitToken(type:String, rawValue:String, ?value:Dynamic) {
        if (value == null) value = rawValue;
        return new Token(type, value, rawValue, this.stringOffset, this.stringOffset + ((rawValue != null) ? rawValue.length : 0), null);
    }

    /**
	 *
	 */
    public function readNext(): Token {
        //this.end = false;
        while (!this.end && this.stringReader.hasMore()) {
            if (this.stringReader.findRegexp(~/^\-?[%\}]\}/).matchesAtStart()) {
                this.end = true;
                continue;
            }
    
            this.stringOffset = this.stringReader.getOffset();
            var currentChar = this.stringReader.peekChars(1);
            var token;
            //console.log(currentChar);
    
            switch (currentChar) {
                // Spaces: ignore.
                //case ' ', '\t', '\r', '\n', '\v':
                case ' ', '\t', '\r', '\n':
                    this.stringReader.skipChars(1);
                // String:
                case '\'': case '"':
                    //throw(new Error("Strings not implemented"));
                    var result = this.stringReader.findRegexp(~/^(["'])(?:(?=(\\?))\2.)*?\1/);
                    if (result.noMatchesAtStart()) throw "Invalid string";
                    var value = this.stringReader.readChars(result.length);
                    try {
                        if (value.charAt(0) == "'") {
                            // @TODO: fix ' escape characters
                            return this.emitToken('string', value, value.substr(1, value.length - 2));
                        } else {
                            return this.emitToken('string', value, Json.parse(value));
                        }
                    } catch (e:Dynamic) {
                        throw "Can't parse [" + value + "]";
                    }
                default:
                    // Numbers
                    if (~/^\d$/.match(currentChar)) {
                        var result = this.stringReader.findRegexp(~/^(0b[0-1]+|0x[0-9A-Fa-f]+|0[0-7]*|[1-9]\d*(\.\d+)?)/);
                        if (result.noMatchesAtStart()) throw "Invalid numeric";
                        var value = this.stringReader.readChars(result.length);
                        return this.emitToken('number', value, RuntimeUtils2.interpretNumber(value));
                    } else {
                        var operatorIndex = -1;
                        var _parts;
                        var currentChars = this.stringReader.peekChars(5);

                        // Found a bit operator
                        var bitop = ~/^(b-and|b-or|b-xor)/;
                        var idex = ~/^[a-z_\$]$/i;
                        
                        if (bitop.match(currentChars)) {
                            var operator = bitop.matched(0);
                            return this.stringReader.skipChars(operator.length, this.emitToken('operator', operator));
                        }
                        // Found a 3 character operator.
                        else if (-1 != (operatorIndex = ExpressionTokenizer.operators3.indexOf(currentChars.substr(0, 3)))) {
                            return this.stringReader.skipChars(3, this.emitToken('operator', currentChars.substr(0, 3)));
                        }
                        // Found a 2 character operator.
                        else if (-1 != (operatorIndex = ExpressionTokenizer.operators2.indexOf(currentChars.substr(0, 2)))) {
                            return this.stringReader.skipChars(2, this.emitToken('operator', currentChars.substr(0, 2)));
                        }
                        // Found a 1 character operator.
                        else if (-1 != (operatorIndex = ExpressionTokenizer.operators1.indexOf(currentChar))) {
                            return this.stringReader.skipChars(1, this.emitToken('operator', currentChar));
                        }
                        // An ID
                        else if (idex.match(currentChar)) {
                            var result = this.stringReader.findRegexp(~/^[a-z_\$]\w*/i);
                            if (result.noMatchesAtStart()) throw "Assertion failed! Not expected!";
                            var value = this.stringReader.readChars(result.length);
                            return this.emitToken('id', value);
                        } else {
                            this.stringReader.skipChars(1);
                            throw "Unknown token '" + currentChar + "' in '" + this.stringReader.peekChars(10) + "'";
                            return this.emitToken('unknown', currentChar);
                        }
                    }
            }
        }
    
        //console.log(tokens);
        
        return this.emitToken('eof', null);
        //return null;
    }
}
