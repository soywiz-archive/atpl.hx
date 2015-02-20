package lexer;
/**
 * StringReader
 */
class StringReader {
    public var position = 0;
    public var currentLine = 1;
    public var string:String;

    /**
	 * Creates a StringReader with a string.
	 *
	 * @param string String to read.
	 */
    public function new(string: String) {
        this.string = string;
    }

    /**
	 * Gets the position.
	 */
    public function getOffset() {
        return this.position;
    }

    public function getSlice(start:Int, end:Int) {
        return this.string.substr(start, end - start);
    }

    public function getSliceWithCallback(callback: Void -> Void) {
        var start = this.getOffset();
        callback();
        var end = this.getOffset();
        return this.getSlice(start, end);
    }

    /**
	 * Determines if the stream has more characters to read.
	 */
    public function hasMore() {
        return this.getLeftCount() > 0;
    }

    /**
	 * Obtains the number of characters remaining in the stream.
	 */
    public function getLeftCount() {
        return this.string.length - this.position;
    }

    /**
	 * Skips reading some characters.
	 *
	 * @param count Number of characters to skip
	 */
    public function skipChars<T>(count, ?ret:T) {
        this.currentLine += this.string.substr(this.position, count).split("\n").length - 1;
        this.position    += count;
        return ret;
    }

    /**
	 * Read all the remaining characters as a string.
	 */
    public function readLeft() {
        return this.readChars(this.getLeftCount());
    }

    /**
	 * Peeks a number of characters allowing them to be readed after.
	 *
	 * @param count Number of characters to peek.
	 */
    public function peekChars(count):String {
        return this.string.substr(this.position, count);
    }

    /**
	 * Reads a number of characters as a string.
	 *
	 * @param count Number of characters to read.
	 */
    public function readChars(count):String {
        var str = this.peekChars(count);
        this.skipChars(count);
        return str;
    }

    /**
	 * Reads a single character as a string.
	 */
    public function readChar():String {
        return this.readChars(1);
    }

    /**
	 * Locates a regular expression in the remaining characters.
	 * Returns the position and length of the match.
	 *
	 * @param regexp Regular expression to find
	 */
    public function findRegexp(regexp: EReg):MatchResult {
        var match = regexp.match(this.string.substr(this.position));
        //if (!match) return new MatchResult(false, 0, 0);
        if (!match) return new MatchResult(false, -1, -1);
        //trace(regexp);
        var pos = regexp.matchedPos();
        return new MatchResult(true, pos.pos, pos.len);
    }
}