package runtime;

class Scope  {
    private var scope: any = {};

    public function new(scope: any) {
        this.scope = scope;
    }

    /**
	 * Creates a new scope temporarlly (while executing the callback).
	 * Writting variables will set temporarily in the new scope, while
	 * reading will try to get the value from the new scope and then
	 * in following scopes.
	 *
	 * @param inner Callback where the new scope will be available.
	 */
    public function createScope(inner: Void -> Void) {
        var newScope = {};
        var oldScope = this.scope;
        newScope['__proto__'] = oldScope;
        this.scope = newScope;
        try {
            return inner();
        } finally {
            this.scope = oldScope;
        }
    }

    /**
	 * Obtains the parent scope.
	 */
    public function getParent() {
        return this.scope['__proto__'];
    }

    /**
	 * Gets a value in the most recent available scope.
	 */
    public function get(key: string): any {
        return this.scope[key];
    }

    /**
	 * Gets all the scope values. (slow)
	 */
    public function getAll() {
        var object = {};
        var parentScope = this.getParent();
        if (Std.is(parentScope, Scope)) object = parentScope.getAll();
        for (key in this.scope) object[key] = this.scope[key];
        return object;
    }

    /**
	 * Sets a value in the scope
	 */
    public function set(key: string, value: any): any {
        return this.scope[key] = value;
    }

    /**
	 * Sets a list of values in the current scope.
	 */
    public function setAll(object: any): void {
        for (key in object) this.set(key, object[key]);
    }
}