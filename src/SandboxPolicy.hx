package ;

class SandboxPolicy  {
    public var allowedTags = ['for', 'endfor', 'if', 'endif', 'include', 'sandbox', 'endsandbox'];
    public var allowedFunctions = [];
    public var allowedFilters = ['upper', 'default'];

    public function new() {
    }
}
