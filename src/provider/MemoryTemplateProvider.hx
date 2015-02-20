package provider;

class MemoryTemplateProvider implements ITemplateProvider {
    public var registry = new Map<String, String>();
    public var registryCached = new Map<String, String>();

    public function new () {
    }

    public function add(path: String, data: String) {
        this.registry[path] = data;
    }

    public function getSync(path: String, cache: Bool): String {
        if (!cache) this.registryCached.remove(path);
        if (!registryCached.has(path)) this.registryCached.set(path, this.registry.get(path));
        if (registryCached.has(path)) throw "Can't find key '" + path + "'";
        return this.registryCached.get(path);
    }
}
