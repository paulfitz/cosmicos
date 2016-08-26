// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class ParseCodec implements Codec {
    private var vocab : Vocab;
    private var top : Bool;

    public function new(vocab: Vocab, top=true) {
        this.vocab = vocab;
        this.top = top;
    }

    public function encode(src: Statement) : Bool {
        var txt : String = cast src.content[0];
        src.content = Parse.stringToList(txt, vocab);
        return true;
    }

    public function decode(src: Statement) : Bool {
        // Decoded version may not match encoded version, but should
        // evaluate to same thing.
        trace("]]]" + src.content);
        if (top) {
            src.content = [flatten(src.content, 0) + ";"];
        } else {
            src.content = [flatten(src.content, 1)];
        }
        return true;
    }

    private function flatten(v: Dynamic, level: Int) : String {
        if (Std.is(v, Array)) {
            var ei : Array<Dynamic> = cast v;
            var txts : Array<String> = [];
            var len : Int = ei.length;
            var has_flattener : Bool = false;
            for (i in 0...len) {
                if (i == 0 && ei[i] < 0) {
                    has_flattener = true;
                    continue;
                }
                txts.push(flatten(ei[i], level + 1));
            }
            var result : String = txts.join(" ");
            if (has_flattener) {
                if (len == 2) {
                    result = "$" + result;
                } else {
                    result = "| " + result;
                }
            } else {
                if (level > 0) result = "(" + result + ")";
            }
            return result;
        }
        return Std.string(v);
    }
}
