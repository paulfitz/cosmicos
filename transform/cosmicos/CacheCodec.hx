// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class CacheCodec implements Codec {
    private var codec : Codec;
    public var cache : Statement;

    public function new(codec : Codec) {
        this.codec = codec;
        this.cache = null;
    }

    public function get() : Statement {
        return cache;
    }

    public function encode(src: Statement) : Bool {
        var result = codec.encode();
        cache = src.copy();
        return result;
    }

    public function decode(src: Statement) : Bool {
        cache = src.copy();
        return codec.decode();
    }
}
