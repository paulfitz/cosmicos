// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class PreprocessCodec implements Codec {
    public var config : Config;

    public function new(state : State) {
        this.config = state.getConfig();
    }

    public function encode(src: Statement) : Bool {
        if (!config.useFlattener()) {
            src.content[0] = Parse.removeFlatteningSyntax(src.content[0]);
        }
        return true;
    }

    public function decode(src: Statement) : Bool {
        return true;
    }
}
