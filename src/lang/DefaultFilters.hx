package lang;
import runtime.RuntimeUtils;
class DefaultFilters {
    /**
     * Filter that obtains the absolute value of a number.
     *
     * @param value Value
     *
     * @see http://twig.sensiolabs.org/doc/filters/abs.html
     */
    static public function abs(value: Float) {
        return Math.abs(value);
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/batch.html
     */
    static public function batch(_items: Dynamic[], groupCount: Float) {
        var items = RuntimeUtils.ensureArray(_items);
        var groupList = [];
        groupCount = RuntimeUtils.ensureNumber(groupCount);

        for (var n = 0; n < items.length; n += groupCount) {
        groupList.push(items.slice(n, n + groupCount));
        }

        return groupList;
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/capitalize.html
     */
    static public function capitalize(value: String) {
        return RuntimeUtils.capitalize(value);
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/convert_encoding.html
     */
    static public function convert_encoding(value: String, from: String, to: String) {
        throw "Not implemented [no use on javascript that works with unicode]";
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/date.html
     */
    static public function date(value: Dynamic, ?format:String, ?timezone:String) {
        return RuntimeUtils.date(format, value, timezone);
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/date_modify.html
     */
    static public function date_modify(value: Dynamic, modifier: Dynamic) {
        return RuntimeUtils.strtotime(modifier, value);
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/default.html
     */
    static public function $default(value: String, default_value: Dynamic) {
        return RuntimeUtils.$default(value, default_value);
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/escape.html
     */
    static public function e(value: String, ?strategy: String) {
        var runtimeContext: RuntimeContext.RuntimeContext = this;
        runtimeContext.currentAutoescape = strategy;
        return value;
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/escape.html
     */
    static public function escape(value: string, strategy: any = true) {
        var runtimeContext: RuntimeContext.RuntimeContext = <any>this;
        runtimeContext.currentAutoescape = strategy;
        return value;
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/format.html
     */
    static public function format(format: string, parameters: Array<Dynamic>) {
        return RuntimeUtils.sprintf.apply(null, arguments);
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/join.html
     */
    static public function join(value: any, separator: string = '') {
        if (!RuntimeUtils.defined(value)) return '';
        if (Std.is(value, Array)) {
            return value.join(separator);
        } else {
            return value;
        }
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/json_encode.html
     */
    static public function json_encode(value: Dynamic) {
        //var runtimeContext: RuntimeContext.RuntimeContext = this;
        //runtimeContext.currentAutoescape = false;
        return RuntimeUtils.json_encode_circular(value);
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/keys.html
     */
    static public function keys(value: any) {
        if (!RuntimeUtils.defined(value)) return [];
        if (RuntimeUtils.isString(value)) return [];
        var keys = [];
        for (key in value) keys.push(key);
        return keys;
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/length.html
     */
    static public function $length(value: any) {
        if (!RuntimeUtils.defined(value)) return 0;
        return value.length;
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/first.html
     */
    static public function first(value: any) {
        if (!RuntimeUtils.defined(value)) return undefined;
        if (RuntimeUtils.isArray(value)) return value[0];
        if (RuntimeUtils.isString(value)) return value.substr(0, 1);
        if (RuntimeUtils.isObject(value)) for (k in value) return value[k];
        return undefined;
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/last.html
     */
    static public function last(value: Dynamic) {
        if (!RuntimeUtils.defined(value)) return undefined;
        if (RuntimeUtils.isArray(value)) return value[value.length - 1];
        if (RuntimeUtils.isString(value)) return value.substr(-1, 1);
        if (RuntimeUtils.isObject(value)) { var last; for (var k in value) last = value[k]; return last; }
        return undefined;
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/lower.html
     */
    static public function lower(value: Dynamic) {
        return String(value).toLowerCase();
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/merge.html
     */
    static public function merge(value: any, add: any): any {
        if (RuntimeUtils.isArray(value)) {
            return (<any[]>value).concat(add);
        } else {
            var object = {};
            for (key in value) object[key] = value[key];
            for (key in add) object[key] = add[key];
            return object;
        }
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/nl2br.html
     */
    static public function nl2br(value: any) {
        var runtimeContext: RuntimeContext.RuntimeContext = <any>this;
        value = runtimeContext.getEscapedText(value);
        runtimeContext.currentAutoescape = false;
        return String(value).replace(/\n/g, '<br />\n');
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/number_format.html
     */
    static public function number_format(value: any, decimal: number = 0, decimal_point: string = '.', decimal_sep: string = ',') {
        return RuntimeUtils.number_format(value, decimal, decimal_point, decimal_sep);
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/raw.html
     */
    static public function raw(runtimeContext: RuntimeContext, value: Stirng) {
        runtimeContext.currentAutoescape = false;
        return value;
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/replace.html
     */
    static public function replace(value: String, replace_pairs: Dynamic) {
        return String(value).replace(new RegExp("(" + Object.keys(replace_pairs).map(item => RuntimeUtils.quoteRegExp(item)).join('|') + ")", "g"), (match) => {
            return replace_pairs[match];
        });
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/reverse.html
     */
    static public function reverse(value: Dynamic) {
        if (!RuntimeUtils.defined(value)) return value;
        if (RuntimeUtils.isArray(value)) return value.reverse();
        if (RuntimeUtils.isNumber(value)) value = value.toString();
        if (RuntimeUtils.isString(value)) {
            var ret = '';
            for (var n = 0; n < value.length; n++) ret += value.charAt(value.length - n - 1);
            return ret;
        }
        //if (typeof value == 'string')
        throw (new Error("Not implemented filter [reverse] with value type [" + (typeof value) + ']'));
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/slice.html
     */
    static public function slice(value: Dynamic, start, length, preserve_keys?) {
        if (RuntimeUtils.isArray(value)) return (<any[]>value).slice(start, start + length);
        if (RuntimeUtils.isNumber(value)) value = value.toString();
        if (RuntimeUtils.isString(value)) return (<string>value).substr(start, length);
        return value;
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/sort.html
     */
    static public function sort(value: any) {
        if (Std.is(value, Array)) return value.sort();
        return value;
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/split.html
     */
    static public function split(_value: any, delimiter: string, limit: number) {
        var value = RuntimeUtils.toString(_value);
        return RuntimeUtils.split(value, delimiter, limit);
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/striptags.html
     */
    static public function striptags(value: Dynamic) {
        return RuntimeUtils.strip_tags(value);
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/title.html
     */
    static public function title(value: Dynamic) {
        return RuntimeUtils.title(value);
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/trim.html
     */
    static public function trim(value: Dynamic, ?characters: String) {
        return RuntimeUtils.trim(value, characters);
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/upper.html
     */
    static public function upper(value: Dynamic) {
        return String(value).toUpperCase();
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/url_encode.html
     */
    static public function url_encode(value: Dynamic) {
        return RuntimeUtils.escapeUrlString(String(value)).replace('%20', '+');
    }

    /**
     *
     * @see http://twig.sensiolabs.org/doc/filters/spaceless.html
     */
    static public function spaceless(value: Dynamic) {
        return RuntimeUtils.toString(value).replace(~/>\s+</g, '><');
    }
}
