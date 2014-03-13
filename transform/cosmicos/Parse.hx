// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Parse {
    public static function stringToList(x: String,
                                        vocab: Vocab) : Dynamic {
        var result : Array<Dynamic> = [];
        x = " " + x + " )";
        var cache = "";
        var level = 0;
        for (i in 0...x.length) {
            var ch = x.charAt(i);
            if (ch=='\n'||ch=='\r'||ch==';') ch = ' ';
            if (ch=='(') {
                level++;
                if (level==1) continue;
            }
            if (ch=='/' && level==0) {
                level = 1;
                continue;
            }
            if (ch==')') {
                level--;
                if (level==0) {
                    result.push(stringToList(cache,vocab));
                    cache = "";
                    continue;
                }
            }
            if (ch!=' '||level>0) cache += ch;
            if (level==0&&ch==' '&&cache.length>0) {
                var nest = false;
                if (cache.charAt(0)=='$') {
                    cache = cache.substr(1,cache.length-1);
                    nest = true;
                    result.push([cache]);
                } else {
                    result.push(cache);
                }
                cache = "";
            }
        }
        return result;
    }

    public static function encodeSymbols(e: Array<Dynamic>,
                                         vocab: Vocab) {
        for (i in 0...e.length) {
            var v : Dynamic = e[i];
            if (Std.is(v,Array)) {
                var ei : Array<Dynamic> = cast v;
                encodeSymbols(ei,vocab);
            } else {
                var str : String = cast v;
                var ch0 = str.charAt(0);
                if (ch0<'0'||ch0>'9') {
                    v = vocab.get(str);
                } else {
                    v = Std.parseInt(str);
                }
                e[i] = v;
            }
        }
    }
}
