package lexer;

class Token {
    public var type: String;
    public var value: Dynamic;
    public var rawValue: Dynamic;
    public var stringOffset: Dynamic;

    public function new(type: String, value: Dynamic, rawValue: Dynamic, stringOffset: Dynamic) {
        this.type = type;
        this.value = value;
        this.rawValue = rawValue;
        this.stringOffset = stringOffset;
    }
}
