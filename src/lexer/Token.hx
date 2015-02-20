package lexer;

class Token {
    public var type: String;
    public var value: Dynamic;
    public var rawValue: Dynamic;
    public var offsetStart: Int;
    public var offsetEnd: Int;
    public var params: Dynamic;

    public function new(type: String, value: Dynamic, rawValue: Dynamic, offsetStart: Int, offsetEnd: Int, params: Dynamic) {
        this.type = type;
        this.value = value;
        this.rawValue = rawValue;
        this.offsetStart = offsetStart;
        this.offsetEnd = offsetEnd;
        this.params = params;
    }
}
