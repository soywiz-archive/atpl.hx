package lang;

class DefaultTests {
// http://twig.sensiolabs.org/doc/tests/constant.html
    static public function constant(value: string, constant: string) {
        throw "Not implemented test [constant] [no use on javascript]";
    }

    // http://twig.sensiolabs.org/doc/tests/defined.html
    static public function defined(value: Dynamic) {
        return RuntimeUtils.defined(value);
    }

    // http://twig.sensiolabs.org/doc/tests/divisibleby.html
    static public function divisibleby(value: any, right: any) {
        return (value % right) == 0;
    }

    // http://twig.sensiolabs.org/doc/tests/empty.html
    static public function empty(value: any) {
        return RuntimeUtils.empty(value);
    }

    // http://twig.sensiolabs.org/doc/tests/even.html
    static public function even(value: any) {
        return (value % 2) == 0;
    }

    // http://twig.sensiolabs.org/doc/tests/iterable.html
    static public function iterable(value: any) {
        if (RuntimeUtils.isArray(value)) return true;
        if (RuntimeUtils.isObject(value) && (value != null)) return true;
        return false;
    }

    // http://twig.sensiolabs.org/doc/tests/null.html
    static public function $null(value: any) {
        return (value == null);
    }

    // http://twig.sensiolabs.org/doc/tests/odd.html
    static public function odd(value: any) {
        return (value % 2) == 1;
    }

    // http://twig.sensiolabs.org/doc/tests/sameas.html
    static public function sameas(value: Dynamic, right: Dynamic) {
        return (value == right);
    }
}
