package ;

class TemplateConfig  {
    public var cache: Bool;
    
    public function new(cache = true) {
        this.cache = cache;
    }

    public function setCacheTemporal<T>(value: Bool, callback: Void -> T): T {
        var oldValue = this.cache;
        this.cache = value;
        try {
            return callback();
        } finally {
            this.cache = oldValue;
        }
    }

    public function getCache() {
        return this.cache;
    }
}
