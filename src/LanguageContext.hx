package ;

/**
 * Reusable context that holds tag, function, filter and test definitions.
 */
class LanguageContext {
    public var tags: any = {};
    public var functions: any = {};
    public var filters: any = {};
    public var tests: any = {};
    public var templateConfig: TemplateConfig;

    public function new(templateConfig: TemplateConfig = null) {
        this.templateConfig = templateConfig;
        if (this.templateConfig == null) this.templateConfig = new TemplateConfig(true);
    }

    private function _registerSomethingItem(object: Dynamic, key: String, value: Dynamic) {
        object[key.replace(~/^\$+/, '')] = value;
    }

    private function _registerSomething(object: Dynamic, list: Dynamic) {
        if (list == null) return;
        for (key in list) this._registerSomethingItem(object, key, list[key]);
    }

    public function registerExtension(container: Dynamic) {
        this.registerTags(container.tags);
        this.registerFunctions(container.functions);
        this.registerFilters(container.filters);
        this.registerTests(container.tests);
    }

    public function registerTags(tags: Dynamic) {
        this._registerSomething(this.tags, tags);
    }

    public function registerFunctions(functions: Dynamic) {
        this._registerSomething(this.functions, functions);
    }

    public function registerFilters(filters: Dynamic) {
        this._registerSomething(this.filters, filters);
    }

    public function registerTests(tests: Dynamic) {
        this._registerSomething(this.tests, tests);
    }
}
