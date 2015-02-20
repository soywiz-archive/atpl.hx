package lexer;

interface ITokenizer {
    function hasMore(): Bool;
    function readNext(): Dynamic;
    function tokenizeAll(): Array<Token>;
    //var stringReader: StringReader;
}
