// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Evaluate {
    private var vocab : Vocab;
    private var mem : Memory;
    private var id_lambda : Int;
    private var id_define : Int;
    private var id_if : Int;
    private var id_assign : Int;
    private var id_translate : Int;

    public function evaluateInContext(e0: Dynamic, c: Memory) : Dynamic {
        if (Std.is(e0,String)) {
            var str : String = cast e0;
            if (str.length==0 || str.charAt(0) == '1') {
                return str.length;
            }
            return str;
        }
        if (Std.is(e0,Int)) {
            return e0;
        }
        //trace("working on " + Parse.deconsify(e0));
        var cursor = new Cursor(e0);
        var x : Dynamic = evaluateInContext(cursor.next(),c);
        if (x==id_lambda) { // ?
            var k2 : Int = evaluateInContext(cursor.next(),c);
            var e2 : Dynamic = cursor.next();
            return function(v) {
                var c2 = new Memory(c,k2,v);
                return evaluateInContext(e2,c2);
            };
        } else if (x==id_assign) { // not super needs
            var k2 : Int = evaluateInContext(cursor.next(),c);
            var v2 : Int = evaluateInContext(cursor.next(),c);
            var c2 = new Memory(c,k2,v2);
            return evaluateInContext(cursor.next(),c2);
        } else if (x==id_define) { // @
            var k2 = cursor.next();
            var v2 = evaluateInContext(cursor.next(),c);
            var code = evaluateInContext(k2,c);
            c.add(code,v2);
            return 1;
        } else if (x==id_if) { // if
            var choice = evaluateInContext(cursor.next(),c);
            if (choice!=0) {
                return evaluateInContext(cursor.next(),c);
            } else {
                cursor.next();
                return evaluateInContext(cursor.next(),c);
            }
        } else {
            var x0 : Dynamic = x;
            var len = cursor.length();
            //trace("== " + len + " ==");
            if (Std.is(x,Int)) {
                var j : Int = cast x;
                x = c.get(j);
                if (len>0) {
                    if (x == null) {
                        trace("Problem with " + j + " (" + vocab.reverse(j) + ")");
                    }
                }
            } else if (Std.is(x,String)) {
                // binary string
                var str : String = cast x;
                var u : Int = 0;
                for (j in 0...str.length) {
                    u *= 2;
                    if (str.charAt(j) == ':') u++;
                }
                x = u;
            }
            for (i in 1...len) {
                var v = cursor.next();
                try {
                    x = x(evaluateInContext(v,c));
                } catch(e : Dynamic) {
                    trace("Problem evaluating " + x + " with " + v + " in " + x0 + " (" + vocab.reverse(x0) + ") from " + Parse.deconsify(e0));
                    throw(e);
                }
            }
            return x;
        }
    }

    public function evaluateExpression(e: Dynamic) : Dynamic {
        return evaluateInContext(e,mem);
    }

    public function evaluateLine(str: String) : Dynamic {
        var lst = Parse.stringToList(str,vocab);
        Parse.encodeSymbols(lst,vocab);
        Parse.removeSlashMarker(lst);
        lst = Parse.consify(lst);
        if (id_translate>=0) {
            var translate = mem.get(id_translate);
            if (translate!=null) {
                lst = translate(lst);
            }
        }
        var lst2 = Parse.deconsify(lst);
        var v = evaluateExpression(lst);
        if (!Std.is(v,Int)) {
            //v = "mu";
        }
        return v;
    }

    public function numberizeLine(str: String) : Dynamic {
        var lst = Parse.stringToList(str,vocab);
        Parse.encodeSymbols(lst,vocab);
        return lst;
    }

    public function codifyLine(str: String) : String {
        var lst = Parse.stringToList(str,vocab);
        Parse.encodeSymbols(lst,vocab);
        return Parse.codify(lst);
    }

    public function new() {
        mem = new Memory(null);
        vocab = new Vocab();
        id_lambda = vocab.get("?");
        id_define = vocab.get("@");
        id_if = vocab.get("if");
        id_assign = vocab.get("assign");
        id_translate = -1;
    }

    public function applyOldOrder() {
        mem = new Memory(null);
        vocab.clear();
        vocab.check("intro",0);
        vocab.check("<",1);
        vocab.check("=",2);
        vocab.check(">",3);
        vocab.check("not",4);
        vocab.check("and",5);
        vocab.check("or",6);
        
        vocab.check("demo",7);
        vocab.check("equal",8);
        vocab.check("*",9);
        vocab.check("+",10);
        vocab.check("-",11);

        id_lambda = vocab.check("?",12);
        id_define = vocab.check("define",13);
        id_assign = vocab.check("assign",14);
        id_if = vocab.check("if",15);
        vocab.check("vector",16);
        vocab.check("unused1",17);
        vocab.check("unused2",18);
        vocab.check("forall",19);
        vocab.check("exists",20);
        vocab.check("cons",21);
        vocab.check("car",22);
        vocab.check("cdr",23);
        vocab.check("number?",24);
        id_translate = vocab.check("translate",25);
        vocab.check("lambda",26);
        vocab.check("make-cell",27);
        vocab.check("set!",28);
        vocab.check("get!",29);
        vocab.check("all",30);
        vocab.check("natural-set",31);
        vocab.check("undefined",32);
        vocab.check("!",33);
        vocab.check("div",34);
        vocab.check("primer",35);

        mem.add(vocab.get("intro"), function(x){ return 1; });
        addStdMin();
        evaluateLine("@ not / ? 0 / if $0 0 1");
        evaluateLine("@ and / ? 0 / ? 1 / if $0 $1 0");
        evaluateLine("@ or / ? 0 / ? 1 / if $0 1 $1");
        mem.add(vocab.get("make-cell"), function(x){ return { data: x }; } );
        mem.add(vocab.get("get!"), function(x){ 
                return x.data; 
            } );
        mem.add(vocab.get("set!"), function(x){ return function(y) { 
                    x.data = y; 
                    return 1; 
                }; } );
        mem.add(vocab.get("number?"), function(x){ return Std.is(x,Int)||Std.is(x,String); } );
        mem.add(vocab.get("translate"), function(x){ 
                if (Std.is(x,Int)||Std.is(x,String)) return x;
                var rep = function(x) {
                }
                var len = Parse.car(x);
                if (len==0) return x;
                var current : Dynamic = mem.get(id_translate);
                if (len==1) return Parse.cons(1,current(Parse.cdr(x)));
                var rep = function(r : Dynamic, len : Int, rec : Dynamic) : Dynamic {
                    if (len==2) return Parse.cons(current(Parse.car(r)),
                                                  current(Parse.cdr(r)));
                    return Parse.cons(current(Parse.car(r)),
                                      rec(Parse.cdr(r),len-1,rec));
                }
                return Parse.cons(len,rep(Parse.cdr(x),len,rep));
            });
        mem.add(vocab.get("forall"), function(f) {
                // try a few samples - not real code, just adequate for message
                return (f(-5)!=0 &&
                        f(10)!=0 &&
                        f(15)!=0 &&
                        f(18)!=0) ? 1 : 0;
            });
        mem.add(vocab.get("exists"), function(f) {
                for (i in -10...20) {
                    if (f(i)!=0) return 1;
                }
                return 0;
            });
        mem.add(vocab.get("all"), function(f) {
                var lst : Array<Int> = [];
                for (i in -50...50) {
                    if (f(i)!=0) {
                        lst.push(i);
                    }
                }
                return Parse.consify(lst);
            });
        mem.add(vocab.get("natural-set"), 
                mem.get(vocab.get("all"))(function (x) { return x>=0; }));
    }

    public function addStdMin() {
        mem.add(vocab.get("+"), function(x){ return function(y){ return x+y; }});
        mem.add(vocab.get("-"), function(x){ return function(y){ return x-y; }});
        mem.add(vocab.get("="), function(x){ return function(y){ return (x==y)?1:0; }});
        mem.add(vocab.get("*"), function(x){ return function(y){ return x*y; }});
        mem.add(vocab.get("<"), function(x){ return function(y){ return (x<y)?1:0; }});
        mem.add(vocab.get(">"), function(x){ return function(y){ return (x>y)?1:0; }});
    }
    
    public function addStd() {
        addStdMin();
        evaluateLine("@ not / ? x / if $x 0 1");
        evaluateLine("@ and / ? x / ? y / if $x $y 0");
        evaluateLine("@ or / ? x / ? y / if $x 1 $y");
    }
    
    static function main() {
#if js
#else
        var e = new Evaluate();
        e.addStd();
        trace(e.evaluateLine("0"));
        trace(e.evaluateLine("? x / x"));
        trace(e.evaluateLine("(? x / x) 15"));
        trace(e.evaluateLine("* 4 5"));
        trace(e.evaluateLine("@ square / ? x / * $x $x"));
        trace(e.evaluateLine("square 40"));
#end
    }
}
