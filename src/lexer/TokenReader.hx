package lexer;

import haxe.Json;
class TokenReader {
//private length: number;
    private var position: Int;
    private var tokens: Array<ExpressionTokenizer.Token> = [];
    private var eof: Bool = false;
    public var tokenizer: ITokenizer;

    public function new (tokenizer: ITokenizer) {
        //this.tokens = tokenizer.tokenizeAll();
        //this.length = this.tokens.length;
        this.position = 0;
        this.tokenizer = tokenizer;
    }

    private function readToken() {
        //if (!this.hasMore()) return false;
        if (!this.tokenizer.hasMore()) return false;
        this.tokens.push(this.tokenizer.readNext());
        return true;
    }

    public function getOffset(): Int {
        return this.position;
    }

    public function getSlice(start: Int, end: Int): Array<ExpressionTokenizer.Token> {
        return this.tokens.slice(start, end);
    }

    public function getSliceWithCallback(readCallback: Void -> Void): Array<ExpressionTokenizer.Token> {
        var start = this.getOffset();
        readCallback();
        var end = this.getOffset();
        return this.getSlice(start, end);
    }

    public function hasMore(): Bool {
        if (this.position < this.tokens.length) return true;
        return this.tokenizer.hasMore();
    }

    public function peek(offset: number = 0): ExpressionTokenizer.Token {
        while (this.tokens.length <= this.position + offset) {
            if (!this.readToken()) return { type: 'eof', value: null, rawValue: null, stringOffset: -1 };
        }
        return this.tokens[this.position + offset];
    }

    public function skip(count: number = 1): Void {
        this.position += count;
    }

    public function read(): ExpressionTokenizer.Token {
        var result = this.peek();
        this.skip(1);
        return result;
    }

    public function checkAndMoveNext(values: Array<String>): String {
        var peekValue = this.peek().value;
        if (values.indexOf(peekValue) != -1) {
            this.skip(1);
            return peekValue;
        }
        return null;
    }

    public function checkAndMoveNextMultiToken(values: Array<String>): String {
        var peekValue1 = this.peek(0).value;
        var peekValue2 = peekValue1 + ' ' + this.peek(1).value;
        
        if (values.indexOf(peekValue2) != -1) {
            this.skip(2);
            return peekValue2;
        }
        
        if (values.indexOf(peekValue1) != -1) {
            this.skip(1);
            return peekValue1;
        }
        
        return null;
    }

    public function expectAndMoveNext(values: Array<String>): String {
        var ret = this.checkAndMoveNext(values);
        //var hasNull = values.indexOf(null) != -1;
        if (ret == null) throw "Expected one of " + Json.stringify(values) + " but get '" + this.peek().value + "'";
        return ret;
    }
}
