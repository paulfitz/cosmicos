// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class CosFunction {
    public var fn : Dynamic;
    public var skip : Bool;
    
    public function new(fn: Dynamic, skip: Bool) {
        this.fn = fn;
        this.skip = skip;
    }
}
