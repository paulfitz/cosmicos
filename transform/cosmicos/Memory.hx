// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Memory {
    public var parent : Memory;
    public var block : Map<Int,Dynamic>;
    public var key : Int;
    public var val : Dynamic;

    public function new(parent: Memory, key : Int = -1, val : Dynamic = null) {
        this.parent = parent;
        this.key = key;
        this.val = val;
        if (key==-1) {
            block = new Map<Int,Dynamic>();
        }
    }

    public function add(key: Int, val: Dynamic) {
        if (block!=null) {
            block.set(key,val);
            return;
        }
        if (parent!=null) {
            parent.add(key,val);
        }
    }

    public function get(key: Int) : Dynamic {
        if (block==null) {
            if (this.key==key) return val;
            if (parent==null) return null;
            return parent.get(key);
        }
        return block.get(key);
    }
}
