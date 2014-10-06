// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

// temporary workaround to support old lesson, this should be going away soon
@:expose
class BitString {
    public var txt : String;
    public function new(txt: String) {
        this.txt = txt;
    }
}
