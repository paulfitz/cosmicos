// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class CosDefine {
    public var k : Dynamic;
    public var v : Dynamic;
    
    public function new(k: Dynamic, v: Dynamic) {
        this.k = k;
        this.v = v;
    }
}