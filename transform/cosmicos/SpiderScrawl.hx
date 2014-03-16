// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class SpiderScrawl {
    private static var mid_color : Array<Int> = [0,0,255];
    private static var blue : Array<Int> = [0,0,255];
    private static var bits = 4;
    private var w : Int;
    private var h : Int;
    private var ww : Int;
    private var hh : Int;
    private var im_x : Int;
    private var im_y : Int;
    private var im_dirty : Bool;
    private var im : SpiderImage;
    private var mode : Bool;
    private var paren : Int;
    private var q : String;
    private var last4 : String;

    public function new(im : SpiderImage, ww: Int, hh: Int,
                        w: Int = 32, h: Int = 32) {
        this.im = im;
        this.ww = ww;
        this.hh = hh;
        this.w = w;
        this.h = h;
        im_x = 0;
        im_y = 0;
        im_dirty = false;
        mode = false;
        paren = 0;
        q = "";
        last4 = "";
    }

    public function line(x0: Float, y0: Float, x1: Float, y1: Float, color: Array<Int>) {
        // ignore color, that is from old code
        if (im!=null) {
            im.moveTo(x0,y0);
            im.lineTo(x1,y1);
        } else {
            //trace(x0 + "," + y0 + " " + x1 + "," + y1);
        }
    }

    public function showMid(im: SpiderImage, x0: Int, y0: Int, dx: Int, dy: Int) {
        var s : Float = w*0.75*0.5;
        line(w/2+s*dx+x0,h/2+s*dy+y0,
             w/2-s*dx+x0,h/2-s*dy+y0,
             mid_color);
    }

    public function showEdge(im: SpiderImage, x0: Int, y0: Int, dx: Int, dy: Int) {
        var s : Float = w*0.75*0.5;
        line(w/2+s*dx+s*dy+x0,h/2+s*dy-s*dx+y0,
             w/2+s*dx-s*dy+x0,h/2+s*dy+s*dx+y0,
             blue);
    }

    public function showCorner(im: SpiderImage, x0: Int, y0: Int, dx: Int, dy: Int, dir: Bool) {
        var s : Float = w*0.75*0.5*0.5;
        if (dir) {
            line(w/2+x0,h/2+y0,
                 w/2+s*2*dx+x0,h/2+s*2*dy+y0,
                 blue);
        } else {
            line(w/2+s*dx+s*dy+x0,h/2+s*dy-s*dx+y0,
                 w/2+s*dx-s*dy+x0,h/2+s*dy+s*dx+y0,
                 blue);
        }
    }

    public function showPart(im: SpiderImage, x0: Int, y0: Int, id: Int) {
        if (id==0) {
            showEdge(im,x0,y0,0,-1);
        } else if (id==1) {
            showEdge(im,x0,y0,-1,0);
        } else if (id==2) {
            showEdge(im,x0,y0,0,1);
        } else if (id==3) {
            showEdge(im,x0,y0,1,0);
        } else if (id==4) {
            showCorner(im,x0,y0,-1,-1,true);
        } else if (id==5) {
            showCorner(im,x0,y0,-1,1,true);
        } else if (id==6) {
            showCorner(im,x0,y0,1,1,true);
        } else if (id==7) {
            showCorner(im,x0,y0,1,-1,true);
        } else {
            throw("UNKNOWN PART");
        }
    }

    public function showCharGlyphZag(im : SpiderImage,
                                     x0 : Int,
                                     y0 : Int,
                                     has_num: Bool,
                                     num : Int,
                                     open : Bool,
                                     close : Bool) {
        var all : Int = 0;

        if (has_num) {
            if (num == 0) {
                showCorner(im,x0,y0,-1,-1,false);
                showCorner(im,x0,y0,-1,1,false);
                showCorner(im,x0,y0,1,-1,false);
                showCorner(im,x0,y0,1,1,false);
            }
        }
    
        if (open) {
            showPart(im,x0,y0,1);
            showPart(im,x0,y0,2);
        }
    
        if (close) {
            showPart(im,x0,y0,0);
            showPart(im,x0,y0,3);
        }
        
        if (num>0) {
            var n : Int = num;
            for (i in 0...4) {
                if (n%2!=0) {
                    if (i==0) {
                        showMid(im,x0,y0,0,1);
                    } else if (i==1) {
                        showPart(im,x0,y0,4);
                        showPart(im,x0,y0,6);
                    } else if (i==2) {
                        showMid(im,x0,y0,1,0);
                    } else if (i==3) {
                        showPart(im,x0,y0,5);
                        showPart(im,x0,y0,7);
                    }
                }
                n = Std.int((n-n%2)/2);
            }
        }
    }

    public function showCharGlyph(im : SpiderImage,
                                  x0 : Int,
                                  y0 : Int,
                                  has_num: Bool,
                                  num : Int,
                                  open : Bool,
                                  close : Bool) {
        if (im!=null) im.beginPath();
        showCharGlyphZag(im,x0,y0,has_num,num,open,close);
        if (im!=null) im.stroke();
    }

    public function incLine() {
        if (im_x!=0) {
            im_x = 0;
            im_y += h;
            if (im_y+h>hh) {
                flushImage();
            }
        }
    }

    public function flushImage() {
    }

    public function incPos() {
        im_x += w;
        if (im_x+w>ww) {
            incLine();
        }
    }

    public function showChar(has_num: Bool, n: Int, open: Bool, close: Bool) : String {
        showCharGlyph(im,im_x,im_y,has_num,n,open,close);
        im_dirty = true;
        incPos();
        var idx : Int = (open?1:0);
        idx *= 2;
        idx += (close?1:0);
        idx *= 17;
        idx += has_num?n:16;
        idx += 0xf100;
        return "&#x" + StringTools.hex(idx) + ";";
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

    public static function main() {
        //var ss : SpiderScrawl = new SpiderScrawl();
        //ss.addString("00010223300011022330001110223300011110223300011111022330001111110223300011111110");
    }
}

