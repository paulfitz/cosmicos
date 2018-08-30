// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class ManuscriptStyle {

    private var out : Array<Dynamic>;
    private var need_ws : Bool;

    public function new() {
    }

    public function render(x: Array<Dynamic>) : Array<Dynamic> {
        out = new Array<Dynamic>();
        need_ws = false;
        renderNest(x,false);
        return out;
    }

    public function ws() {
        if (need_ws) {
            out.push(" ");
            need_ws = false;
        }
    }

    public function nws() {
        need_ws = true;
    }
    
    public function renderInt(x: Int) {
        ws();
        out.push(x);
        nws();
    }

    public function renderString(x: String) {
        ws();
        if (x=="") {
            out.push("");
            return;
        }
        var lst = x.split(":");
        for (e in lst) {
            out.push(e);
        }
        nws();
    }

    public function renderNest(x: Array<Dynamic>, nested: Bool) {
        var offset = 0;
        var parens = nested;
        if (x.length>=1) {
            var e = x[0];
            if (e==-1||e==-2) {
                offset = 1;
                if (e==-1) {
                    ws();
                    out.push("|");
                    nws();
                }
                if (e==-2) {
                    ws();
                    out.push("$");
                }
                parens = false;
            }
        }
        if (parens) out.push("(");
        for (i in offset...x.length) {
            var e = x[i];
            if (Std.is(e,String)) {
                renderString(cast e);
            }
            if (Std.is(e,Int)) {
                renderInt(cast e);
            }
            if (Std.is(e,Array)) {
                ws();
                renderNest(cast e,true);
                nws();
            }
        }
        if (parens) out.push(")");
    }
}
