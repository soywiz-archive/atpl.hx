package ;

import lexer.TemplateTokenizer;
import lexer.StringReader;
import lexer.ExpressionTokenizer;
class AtplExample {
    static public function main() {
        //var et = new ExpressionTokenizer(new StringReader("1 + 2"));
        //trace(et.tokenizeAll());
        var et = new TemplateTokenizer("Hello world {% if 1 %}{% endif %}");
        trace(et.tokenizeAll());
        //public function parseString(t:Term, str:String, file:String, ?errors:HaxeErrors):Result return parse(t, new Reader(str, file), errors);
    }
}
