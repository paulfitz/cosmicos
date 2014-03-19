// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Evaluate {
    private var vocab : Vocab;
    private var mem : Memory;
    private var id_lambda : Int;
    private var id_define : Int;
    private var id_if : Int;

    public function evaluateInContext(e0: Dynamic, c: Memory) : Dynamic {
        if (!Std.is(e0,Array)) {
            if (Std.is(e0,String)) {
                var str : String = cast e0;
                if (str.length==0 || str.charAt(0) == '1') {
                    return str.length;
                }
                return str;
            }
            return e0;
        }
        var e : Array<Dynamic> = cast e0;
        var x : Dynamic = evaluateInContext(e[0],c);
        if (x==id_lambda) { // ?
            var k2 : Int = evaluateInContext(e[1],c);
            var e2 : Dynamic = e[2];
            return function(v) {
                var c2 = new Memory(c,k2,v);
                return evaluateInContext(e2,c2);
            };
        } else if (x==id_define) { // @
            var k2 = e[1];
            var v2 = evaluateInContext(e[2],c);
            var code = evaluateInContext(k2,c);
            c.add(code,v2);
            return null;
        } else if (x==id_if) { // if
            var choice = evaluateInContext(e[1],c);
            if (choice!=0) {
                return evaluateInContext(e[2],c);
            } else {
                return evaluateInContext(e[3],c);
            }
        } else {
            if (Std.is(x,Int)) {
                x = c.get(x);
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
            for (i in 1...e.length) {
                x = x(evaluateInContext(e[i],c));
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
        vocab.check("assign",14);
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
        vocab.check("translate",25);
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
        addStd();
        evaluateLine("@ not / ? 0 / if $0 0 1");
        evaluateLine("@ and / ? 0 / ? 1 / if $0 $1 0");
        evaluateLine("@ or / ? 0 / ? 1 / if $0 1 $1");
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
