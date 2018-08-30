// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class ChainCodec implements Codec {
    private var codecs : Array<Codec>;

    public function new(codecs : Array<Codec>) {
        this.codecs = codecs;
    }

    public function encode(src: Statement) : Bool {
        for (i in 0...codecs.length) {
            var result = codecs[i].encode(src);
            if (!result) return result;
        }
        return true;
    }

    public function decode(src: Statement) : Bool {
        for (i in 0...codecs.length) {
            var result = codecs[codecs.length - i - 1].decode(src);
            if (!result) return result;
        }
        return true;
    }

    public function last() : Codec {
        if (codecs.length == 0) return null;
        return codecs[codecs.length - 1];
    }
}
