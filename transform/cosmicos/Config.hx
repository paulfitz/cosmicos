// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Config {
    private var config : Dynamic;

    public function new(txt: String = null) {
        config = null;
        if (txt != null) {
            config = haxe.Json.parse(txt);
        }
    }

    /**
     *
     * Option: is flattener syntax "|" and "$" supported in the message or should
     * these be mapped to parentheses.
     *
     */
    public function useFlattener() : Bool {
        if (config == null) return true;
        return Reflect.field(config, 'use_flattener');
    }

    /**
     *
     *
     * Number of lines of message to work on - 0 means unlimited.  Can be convenient
     * to set to a small number during development.
     *
     */
    public function lines() : Int {
        if (config == null) return 0;
        return Reflect.field(config, 'lines');
    }
}
