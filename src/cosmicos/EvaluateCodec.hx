// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class EvaluateCodec implements Codec {
    public var state : State;
    public var eval : Evaluate;

    public function new(state : State = null, with_std_functions : Bool = true) {
        this.state = state;
        eval = new Evaluate(state);
        eval.applyOldOrder();
        if (with_std_functions) {
            eval.addStdMin();
        }
    }

    public function addPrimer(primer : Dynamic) {
        eval.addPrimer(primer);
    }

    public function encode(src: Statement) : Bool {
        src.content = [eval.evaluateExpression(src.content)];
        return true;
    }

    public function decode(src: Statement) : Bool {
        src.content = src.content[0];
        var r = Cons.deconsify(src.content);
        var vocab = state.getVocab();
        if (vocab.exists("vector")) {
            var vector = vocab.get("vector");
            vectorify(r, vector);
        }
        src.content = Cons.consify(r);
        return true;
    }

    public function vectorify(v: Dynamic, vector: Dynamic) {
        if (Std.is(v, Array)) {
            var ei : Array<Dynamic> = cast v;
            for (i in 0...ei.length) {
                ei[i] = vectorify(ei[i], vector);
            }
            ei.insert(0, vector);
            return ei;
        } else {
            return v;
        }

    }
}
