// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class UnflattenCodec implements Codec {

    public function new() {
    }

    public function encode(src: Statement) : Bool {
        Parse.removeSlashMarker(src.content);
        return true;
    }

    public function decode(src: Statement) : Bool {
        // Decoded version may not match encoded version, but should
        // evaluate to same thing.
        unflatten(src.content, 0);
        return true;
    }

    private function unflatten(v: Dynamic, level: Int) : Void {
        if (Std.is(v, Array)) {
            var ei : Array<Dynamic> = cast v;
            var txts : Array<String> = [];
            var len : Int = ei.length;
            var has_flattener : Bool = false;
            for (i in 0...len) {
                unflatten(ei[i], level + 1);
                if (i == len - 1 && Std.is(ei[i], Array)) {
                    var etail : Array<Dynamic> = cast ei[i];
                    if (etail.length > 0) {
                        if (etail[0] != -1 && etail[0] != -2) {
                            etail.insert(0, -1);
                        }
                    }
                }
            }
            if (len == 1) {
                ei.insert(0, -2);
            }
        }
    }
}
