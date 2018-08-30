// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Cons {

    public static function cons(x:Dynamic,y:Dynamic) {
        return function(f) { return f(x)(y); };
    }

    public static function car(x:Dynamic) {
        return x(function(a) { return function(b) { return a; }});
    }

    public static function cdr(x:Dynamic) {
        return x(function(a) { return function(b) { return b; }});
    }

    public static function deconsify(e: Dynamic) : Dynamic {
        if (Std.is(e,Int)) return e;
        if (Std.is(e,BigInteger)) return e;
        if (Std.is(e,String)) return e;
        if (Std.is(e,BitString)) return e;
        var c = new Cursor(e);
        var lst = new Array<Dynamic>();
        var len = c.length();
        for (i in 0...len) {
            var ei = c.next();
            lst.push(deconsify(ei));
        }
        return lst;
    }

    public static function consify(e: Dynamic) : Dynamic {
        if (!Std.is(e,Array)) return e;
        var lst : Array<Dynamic> = cast e;
        var len : Int = lst.length;
        if (len==0) return cons(0,0);
        if (len==1) return cons(1,consify(lst[0]));
        var r = cons(consify(lst[len-2]),consify(lst[len-1]));
        for (i in 0...(len-2)) {
            r = cons(consify(lst[len-3-i]),r);
        }
        return cons(len,r);
    }
}
