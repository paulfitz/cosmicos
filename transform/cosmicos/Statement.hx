// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Statement {
    public var content : Array<Dynamic>;

    public function new(txt: Dynamic = null) {
        if (txt != null) {
            this.content = [txt];
        } else {
            this.content = null;
        }
    }

    public function copy() : Statement {
        var result = new Statement();
        if (this.content != null) { 
            result.content = copyArray(this.content);
        }
        return result;
    }

    private function copyArray(e : Array<Dynamic>) : Array<Dynamic> {
        var result = new Array<Dynamic>();
        for (i in 0...e.length) {
            var ei = e[i];
            if (Std.is(ei, Array)) {
                result.push(copyArray(cast ei));
            } else {
                result.push(ei);
            }
        }
        return result;
    }
}
