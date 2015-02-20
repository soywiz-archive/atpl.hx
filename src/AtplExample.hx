package ;

import lexer.StringReader;
import lexer.ExpressionTokenizer;
class AtplExample {
    static public function main() {
        var et = new ExpressionTokenizer(new StringReader("1+2"));
        trace(et.tokenizeAll());
    }
}
