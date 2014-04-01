// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Vocab {
    private var nameToCode : Map<String,Int>;
    private var codeToName : Map<Int,String>;
    private var topCode : Int;

    public function new() {
        clear();
    }

    public function clear() {
        nameToCode = new Map<String,Int>();
        codeToName = new Map<Int,String>();
        topCode = 0;
    }

    public function get(name: String) : Int {
        if (name=="define") name = "@";
        if (!nameToCode.exists(name)) {
            nameToCode.set(name,topCode);
            codeToName.set(topCode,name);
            topCode++;
        }
        return nameToCode.get(name);
    }

    public function check(name: String, id : Int) : Int {
        var nid : Int = get(name);
        if (id!=nid) {
            throw("id for " + name + " is unexpected (" + nid + " vs " + id + ")");
        }
        return nid;
    }

    public function reverse(id: Int) : String {
        return codeToName.get(id);
    }

    public function getNames() : Array<String> {
        return [for (i in nameToCode.keys()) i];
    }
}
