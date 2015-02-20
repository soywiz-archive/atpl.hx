package lexer;

interface ITokenizer {
    function hasMore(): Bool;
    function readNext(): Dynamic;
    function tokenizeAll(): Void;
    //var stringReader: StringReader;
}
