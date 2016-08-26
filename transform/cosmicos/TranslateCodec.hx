// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class TranslateCodec implements Codec {
    public var state : State;

    public function new(state : State) {
        this.state = state;
    }

    public function encode(src: Statement) : Bool {
        src.content = Cons.consify(src.content);
        var vocab = state.getVocab();
        if (vocab.exists("translate")) {
            var mem = state.getMemory();
            var translate = mem.get(vocab.get("translate"));
            if (translate!=null) {
                src.content = translate(src.content);
            }
        }
        return true;
    }

    public function decode(src: Statement) : Bool {
        // Cannot undo the translation, but can undo consification
        src.content = Cons.deconsify(src.content);
        trace("Translated");
        trace(src.content);
        return true;
    }
}
