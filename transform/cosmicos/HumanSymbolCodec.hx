// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class HumanSymbolCodec implements Codec {
    public var config : Config;

    public function new(config : Config) {
        this.config = config;
    }

    public function encode(src: Statement) : Bool {
        return true;
    }

    public function decode(src: Statement) : Bool {
        return true;
    }
}
