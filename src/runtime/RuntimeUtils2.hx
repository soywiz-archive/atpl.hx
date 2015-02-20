package runtime;
class RuntimeUtils2 {
    static public function tryFinally<T>(_try: Void -> T, _finally: Void -> Void) {
        try {
            var result = _try();
            _finally();
            return result;
        } catch (e:Dynamic) {
            _finally();
            throw e;
        }
        return null;
    }

    static public function interpretNumber(number:String, radix:Int = -1):Float {
        if (number == '0') return 0;
        if (radix == -1) {
            if (number.substr(0, 2).toLowerCase() == '0x') return interpretNumber(number.substr(2), 16);
            if (number.substr(0, 2).toLowerCase() == '0b') return interpretNumber(number.substr(2), 2);
            if (number.substr(0, 1) == '0') return interpretNumber(number.substr(1), 8);
            radix = 10;
        }
        if (radix == 10) return Std.parseFloat(number);
        return parseInt(number, radix);
    }

    static public function parseInt(number:String, radix:Int = 10):Float {
        // @TODO: Unsupported other radix!
        return Std.parseInt(number);
    }
}
