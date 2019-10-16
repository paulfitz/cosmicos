// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class GlyphCode {
    private var top : Int;
    private var base : Int;
    private var bits : Int;
    private var mode : Bool;
    private var paren : Int;
    private var q : String;
    private var last4 : String;
    private var useSpace : Bool;
    private var needSpace : Bool;

    public function new(flavor: String) {
        if (flavor == "octo") {
            base = 0xf144;
            bits = 6;
            useSpace = true;
        } else {
            base = 0xf100;
            bits = 4;
            useSpace = false;
        }
        top = Std.int(Math.pow(2, bits));
        reset();
    }

    public function reset() {
        mode = false;
        paren = 0;
        q = "";
        last4 = "";
        needSpace = false;
    }

    public function addString(txt: String) {
        var s = "";
        if (useSpace) {
            // sneaking in special rendering of | and $.
            txt = StringTools.replace(txt, "123", "243");
            txt = StringTools.replace(txt, "023", "253");
            txt = StringTools.replace(txt, "2233", "273");
        }
        for (i in 0...txt.length) {
            var ch = txt.substr(i,1);
            if (ch<"0"||ch>"7") {
                if (ch=="\n") {
                    s += "<br />\n";
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
                incLine();
            }
        }
        return s;
    }

    public function incLine() {
    }

    public function incPos() {
    }

    public function showChar1(hasNum: Bool, n: Int, open: Bool, close: Bool) : String {
        var idx : Int = 0;
        if (hasNum) {
            idx = (open?1:0);
            idx *= 2;
            idx += (close?1:0);
            idx *= top;
            idx += n;
        } else {
            idx += 2 * 2 * top;
            idx += n;
            if (n==0) {
                idx += open ? 2 : 0;
                idx += close ? 1 : 0;
            }
        }
        idx += base;
        return "&#x" + StringTools.hex(idx) + ";";
    }

    public function showChar(hasNum: Bool, n: Int, open: Bool, close: Bool) : String {
        var space: String = "";
        if (useSpace) {
            if (hasNum) {
                if (needSpace) {
                    space = showChar1(false, 6, false, false);
                    needSpace = false;
                }
                if (close) {
                    needSpace = true;
                }
                open = false;
                close = false;
            } else {
                needSpace = false;
            }
        }
        incPos();
        return space + showChar1(hasNum, n, open, close);
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
                    if (q == "4" || q == "5" || q == "7") {
                        // sneaking in special rendering of | and $ and EOL.
                        txt += showChar(false, Std.parseInt(q), false, false);
                    } else {
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
}
