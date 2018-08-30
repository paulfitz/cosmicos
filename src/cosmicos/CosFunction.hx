// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class CosFunction {
    public var fn : Dynamic;
    public var meta : Bool;
    
    public function new(fn: Dynamic, meta: Bool) {
        this.fn = fn;
        this.meta = meta;
    }
}
