// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Vocab {
    private var nameToCode : Map<String,Int>;
    private var codeToName : Map<Int,String>;
    private var topCode : Int;

    public function new() {
        nameToCode = new Map<String,Int>();
        codeToName = new Map<Int,String>();
        topCode = 0;
    }

    public function get(name: String) : Int {
        if (!nameToCode.exists(name)) {
            nameToCode.set(name,topCode);
            codeToName.set(topCode,name);
            topCode++;
        }
        return nameToCode.get(name);
    }
}
