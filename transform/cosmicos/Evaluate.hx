// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Evaluate {
    private var vocab : Vocab;
    private var mem : Memory;

    public static function evaluateInContext(e0: Dynamic, c: Memory) : Dynamic {
        if (!Std.is(e0,Array)) return e0;
        var e : Array<Dynamic> = cast e0;
        var x : Dynamic = evaluateInContext(e[0],c);
        if (x==0) { // ?
            var k2 : Int = evaluateInContext(e[1],c);
            var e2 : Dynamic = e[2];
            return function(v) {
                var c2 = new Memory(c,k2,v);
                return evaluateInContext(e2,c2);
            };
        } else if (x==1) { // @
            var k2 = e[1];
            var v2 = evaluateInContext(e[2],c);
            var code = evaluateInContext(k2,c);
            c.add(code,v2);
            return null;
        } else if (x==2) { // if
            var choice = evaluateInContext(e[1],c);
            if (choice!=0) {
                return evaluateInContext(e[2],c);
            } else {
                return evaluateInContext(e[3],c);
            }
        } else {
            if (Std.is(x,Int)) {
                x = c.get(x);
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
        //trace("Working on " + str);
        var lst = Parse.stringToList(str,vocab);
        //trace(lst);
        Parse.encodeSymbols(lst,vocab);
        //trace(lst);
        var v = evaluateExpression(lst);
        if (!Std.is(v,Int)) {
            //v = "mu";
        }
        return v;
    }

    public function new() {
        mem = new Memory(null);
        vocab = new Vocab();
        vocab.get("?");
        vocab.get("@");
        vocab.get("if");
    }

    public function addStd() {
        mem.add(vocab.get("+"), function(x){ return function(y){ return x+y; }});
        mem.add(vocab.get("-"), function(x){ return function(y){ return x-y; }});
        mem.add(vocab.get("="), function(x){ return function(y){ return (x==y)?1:0; }});
        mem.add(vocab.get("*"), function(x){ return function(y){ return x*y; }});
        mem.add(vocab.get("<"), function(x){ return function(y){ return (x<y)?1:0; }});
        mem.add(vocab.get(">"), function(x){ return function(y){ return (x>y)?1:0; }});
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
