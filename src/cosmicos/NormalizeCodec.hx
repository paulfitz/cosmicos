// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class NormalizeCodec implements Codec {
    private var vocab : Vocab;

    public function new(vocab: Vocab) {
        this.vocab = vocab;
    }

    public function encode(src: Statement) : Bool {
        Parse.encodeSymbols(src.content, vocab);
        return true;
    }

    public function decode(src: Statement) : Bool {
        // Decoded version may not match encoded version, but should
        // evaluate to same thing.
        src.content = recover(src.content, 0);
        return true;
    }

    private function recover(v: Dynamic, level: Int) : Dynamic {
        if (Std.is(v, Array)) {
            var ei : Array<Dynamic> = cast v;
            for (i in 0...ei.length) {
                ei[i] = recover(ei[i], level + 1);
            }
            return ei;
        } else {
            return Parse.recover(v);
        }
    }
}
