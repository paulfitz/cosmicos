// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class OghamStyle {
    private static var bits = 4;
    private var mode : Bool;
    private var paren : Int;
    private var q : String;
    private var last4 : String;

    public function new() {
        mode = false;
        paren = 0;
        q = "";
        last4 = "";
    }

    public function showChar(has_num: Bool, n: Int, open: Bool, close: Bool) : String {
        var txt = "";
        if (open) txt += "<";
        if (has_num) {
            txt += "abcdefghijklmnop".charAt(n);
        }
        if (close) txt += ">";
        return txt;
        //return "&#x" + StringTools.hex(idx) + ";";
    }

    public function addChar(ch: String) {
        var txt : String = "";
        if (ch == "2") {
            if (mode) {
                txt += showChar(false,0,true,false);
            } else {
                mode = true;
            }
            paren++;
        } else if (ch == "3") {
            paren--;
            if (mode) {
                if (q.length>100) {
                    txt += showChar(false,0,true,false);
                    for (i in 0...q.length) {
                        txt += showChar(true,Std.parseInt(q.substr(i,1)),false,false);
                    }
                    txt += showChar(false,0,false,true);
                } else if (q.length>0) {
                    var len = q.length;
                    while (len%bits!=0) {
                        q = "0" + q;
                        len = q.length;
                    }
                    var blen = Std.int((len-1)/bits+1);
                    for (i in 0...blen) {
                        var part : String = q.substr(i*bits,bits);
                        var v = 0;
                        for (j in 0...bits) {
                            v *= 2;
                            if (part.charAt(j)=='1') {
                                v++;
                            }
                        }
                        txt += showChar(true,v,(i==0),(i==blen-1));
                    }
                } else {
                    txt += showChar(false,0,true,true);
                }
                q = "";
                mode = false;
            } else {
                txt += showChar(false,0,false,true);
            }
        } else {
            if (mode) {
                q += ch;
            } else {
                txt += showChar(true,Std.parseInt(ch),false,false);
            }
        }
        return txt;
    }

    private function addString(txt: String) {
        var s = "";
        for (i in 0...txt.length) {
            var ch = txt.substr(i,1);
            if (ch<"0"||ch>"3") {
                if (ch=="\n") {
                    //s += "<br />\n";
                    s += "\n";
                }
                continue;
            }
            s += addChar(ch);
            if (last4.length>=4) {
                last4 = last4.substr(1,3) + ch;
            } else {
                last4 = last4 + ch;
            }
            if (last4 == "2233") {
                //incLine();
            }
        }

        s = StringTools.replace(s,"<<>>","&#x1697;");
        s = StringTools.replace(s,"a<>","&#x169A;");

        var result = "";
        /*
        var chars = [ "1696",
                      "1686",
                      "1687",
                      "1688",
                      "1689",
                      "1681",
                      "1682",
                      "1683",
                      "1684",
                      "168B",
                      "168C",
                      "168D",
                      "168E",
                      "1690",
                      "1691",
                      "1692",
                      "1693" ];
        */

        var chars = [ "1681",
                      "1686",
                      "1687",
                      "1688",
                      "1689",
                      "168A",
                      "168B",
                      "168C",
                      "168D",
                      "168E",
                      "168F",
                      "1690",
                      "1691",
                      "1692",
                      "1693",
                      "1694"];
                      
        for (i in 0...s.length) {
            var ch = s.charCodeAt(i);
            if (ch>="a".code && ch<="p".code) {
                var v = ch - "a".code;
                result += "&#x" + chars[v] + ";";
            } else {
                result += s.charAt(i);
            }
        }

        s = result;
        //s = StringTools.replace(result,"<<>>","<<>>\n");
        //s = StringTools.replace(s,"<>","&#x1696;");
        s = StringTools.replace(s,"<","&#x169B;");
        s = StringTools.replace(s,">","&#x169C;");
        s = StringTools.replace(s,"\n","<br />\n");

        return s;
    }

    public static function main() {
        //var ss : OghamStyle = new OghamStyle();
        //trace(ss.addString("00010223300011022332111032100101322101013211302321010132030232101013210302321010132100321330232101322103211302321011030232100101330232101322103203023210110302321011130232100101330232101322103210302321011030232101113023210111302321001013302321013221032100302321011030232101113023210111302321011130232100101332210321302321011130232101113023210111302321011130232100101332233"));
    }
}

