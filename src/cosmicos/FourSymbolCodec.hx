// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class FourSymbolCodec implements Codec {
    public var vocab : Vocab;

    public function new(vocab : Vocab) {
        this.vocab = vocab;
    }

    public function encode(src: Statement) : Bool {
        var txt = Parse.codify(src.content, vocab);
        src.content = [txt];
        return true;
    }

    public function decode(src: Statement) : Bool {
        var txt = src.content[0];
        var out = "";
        var len = txt.length;
        var unit = "";
        var wrap = "";
        for (i in 0...len) {
            var ch = txt.charAt(i);
            if (ch == '0') {
                unit += ".";
                out += wrap;
                wrap = "";
            } else if (ch == '1') {
                unit += ":";
                out += wrap;
                wrap = "";
            } else if (ch == '2') {
                if (wrap == ')') {
                    out += ")";
                    wrap = "";
                }
                if (wrap == '()') {
                    out += "|";
                    wrap = "";
                }
                wrap += "(";
                out += unit;
                unit = "";
            } else if (ch == '3') {
                if (unit != "") {
                    var bs = new BitString(unit);
                    if (bs.small()) {
                        out += "]";
                        out += bs.asInteger();
                        out += "[";
                        unit = "";
                    }
                }
                wrap += ")";
                out += unit;
                unit = "";
                if (wrap == '(())') {
                    wrap = "";
                    out += ";";
                }
            }
        }
        var r = ~/:[|]/g;
        out = r.replace(out, "|");
        r = ~/[.][|]/g;
        out = r.replace(out, "$");
        r = ~/\(\]/g;
        out = r.replace(out, " ");
        r = ~/\[\)/g;
        out = r.replace(out, " ");
        r = ~/\$ +/g;
        out = r.replace(out, "$");
        var codec = new cosmicos.ChainCodec([
                                             new cosmicos.ParseCodec(vocab),
                                             new cosmicos.NormalizeCodec(vocab)
                                             ]);
        var dest = new cosmicos.Statement(out);
        codec.encode(dest);
        src.content = dest.content;
        return true;
    }
}
