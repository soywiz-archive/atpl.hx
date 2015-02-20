package lang;

/**
 *
 */
import runtime.RuntimeContext;
import runtime.RuntimeUtils;
class DefaultFunctions {
/**
	 * Obtains a range of numbers
	 *
	 * @see http://twig.sensiolabs.org/doc/functions/range.html
	 */
    static public function range(low: Int, high: Int, step: Int = 1) {
        return RuntimeUtils.range(low, high, step);
    }

    /**
	 *
	 * @see http://twig.sensiolabs.org/doc/functions/cycle.html
	 */
    static public function cycle(list: Array<Dynamic>, index: Int) {
        return list[index % list.length];
    }

    /**
	 *
	 * @see http://twig.sensiolabs.org/doc/functions/constant.html
	 */
    static public function constant(name: String) {
        throw "Not implemented function [constant] [no use on javascript]";
    }

    /**
	 *
	 * @see http://twig.sensiolabs.org/doc/functions/include.html
	 */
    static public function include(runtimeContext: RuntimeContext, name: String) {
        runtimeContext.include(name);
    }

    /**
	 *
	 * @see http://twig.sensiolabs.org/doc/functions/random.html
	 */
    static public function random(values: Dynamic) {
        if (values == null) {
            return RuntimeUtils.random();
        } else if (RuntimeUtils.isArray(values) || RuntimeUtils.isString(values)) {
            return values[RuntimeUtils.random(0, values.length)];
        } else {
            return RuntimeUtils.random(0, values);
        }
    }

    /**
	 *
	 * @see http://twig.sensiolabs.org/doc/functions/attribute.html
	 */
    static public function attribute(runtimeContext: RuntimeContext, object: Dynamic, method: Dynamic, ?_arguments: Array<Dynamic>) {
        return runtimeContext.accessCall(object, method, _arguments);
    }

    /**
	 *
	 * @see http://twig.sensiolabs.org/doc/functions/block.html
	 */
    static public function block(runtimeContext: RuntimeContext, name: String) {
        return runtimeContext.captureOutput(function () {
            runtimeContext.putBlock('block_' + name);
        });
    }

    /**
	 *
	 * @see http://twig.sensiolabs.org/doc/functions/parent.html
	 */
    static public function parent() {
        var runtimeContext: RuntimeContext.RuntimeContext = <any>this;
        return runtimeContext.autoescape(false, () => {
            return runtimeContext.captureOutput(() => {
                runtimeContext.putBlockParent(runtimeContext.currentBlockName);
            });
        });
    }

    /**
	 *
	 * @see http://twig.sensiolabs.org/doc/functions/dump.html
	 */
    static public function dump(objects: Array<Dynamic>) {
        var runtimeContext: RuntimeContext.RuntimeContext = <any>this;
        if (objects.length > 0) {
            var result = '';
            for (n in 0 ... objects.length) result += RuntimeUtils.inspect_json(objects[n]);
            return result;
        } else {
            return RuntimeUtils.inspect_json(runtimeContext.scope.getAll());
        }
    }

    /**
	 *
	 * @see http://twig.sensiolabs.org/doc/functions/date.html
	 */
    static public function date(?date, ?timezone) {
        if (timezone != null) throw "Not implemented function [date] with [timezone] parameter";
        return RuntimeUtils.strtotime(date);
    }

    /**
	 *
	 * @see http://twig.sensiolabs.org/doc/functions/template_from_string.html
	 */
    static public function template_from_string(template: String) {
        var runtimeContext: RuntimeContext = <any>this;
        return runtimeContext.compileString(template);
    }

    /**
	 *
	 * @see https://github.com/soywiz/atpl.js/issues/13
	 */
    static public function inspect(object, ?showHidden, ?depth, ?color) {
        return util.inspect(object, showHidden, depth, color);
    }
}
