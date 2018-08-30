// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

class Cursor {
    public var at : Int;
    public var e : Dynamic;
    public var len : Int;

    public function new(e: Dynamic) {
        at = 0;
        len = Cons.car(e);
        this.e = Cons.cdr(e);
    }

    public function length() : Int {
        return len;
    }

    public function next() : Dynamic {
        // Expression-as-list is faster, but consing needed for
        // replaceability of translate function
        //var lst : Array<Dynamic> = cast e;
        //var result = lst[at];
        var result = null;
        if (len==1) {
            result = e;
            e = null;
        } else if (at==len-1) {
            result = Cons.cdr(e);
            e = null;
        } else {
            result = Cons.car(e);
            if (at!=len-2) e = Cons.cdr(e);
        }
        at++;
        return result;
    }
}
