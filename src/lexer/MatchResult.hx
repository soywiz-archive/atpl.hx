package lexer;
class MatchResult {
    public var matched:Bool;
    public var position:Int;
    public var length:Int;
    
    public function new(matched:Bool, position:Int, length:Int) {
        this.matched = matched;
        this.position = position;
        this.length = length;
    }

    public function matchesAtStart() { return matchesAt(0); }
    public function noMatchesAtStart() { return noMatchesAt(0); }

    public function matchesAt(index:Int) {
        return this.matched && this.position == index;
    }

    public function noMatchesAt(index:Int) {
        return !matchesAt(index);
    }
}
