// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Evaluate {
    private var vocab : Vocab;
    private var mem : Memory;
    private var id_lambda : Dynamic;
    private var id_lambda0 : Dynamic;
    private var id_define : Dynamic;
    private var id_if : Dynamic;
    private var id_assign : Dynamic;
    private var id_translate : Dynamic;

    public function evaluateInContext(e0: Dynamic, cbase: Memory) : Dynamic {
        var c = cbase;
        var c_is_private = false;
        var more = false;

	trace("eval in context: " + e0);

        do {
            if (Std.is(e0,String)) {
		trace("--> not open string branch \"" + e0 + "\"");
                var str : String = cast e0;
                if (str.length==0 || str.charAt(0) == '1') {
                    return str.length;
                }
		trace("--> returning \"" + e0 + "\"");
                return str;
            }
            if (Std.is(e0,Int)||Std.is(e0,BigInteger)||Std.is(e0,BitString)) {
		trace("--> int branch");
		trace("--> returning \"" + e0 + "\"");
                return e0;
            }
            trace("--> working on " + Parse.deconsify(e0));
            var cursor = new Cursor(e0);
            var x : Dynamic = evaluateInContext(cursor.next(),c);
            if (x==id_lambda) { // ?
		trace("--> lambda branch");
                var k2 : Int = evaluateInContext(cursor.next(),c);
                var e2 : Dynamic = cursor.next();
                return function(v) {
                    var c2 = new Memory(c,k2,v);
                    return evaluateInContext(e2,c2);
                };
            } else if (x==id_lambda0) { // ??
		trace("--> lambda0 branch");
                var k2 : Int = evaluateInContext(cursor.next(),c);
                var e2 : Dynamic = cursor.next();
                return new CosFunction(function(v) {
                        var c2 = new Memory(c,k2,v);
                        return evaluateInContext(e2,c2);
                }, true);
            } else if (x==id_assign) { // not super needs
		trace("--> assign branch");
                var k2 : Int = evaluateInContext(cursor.next(),c);
                var v2 : Int = evaluateInContext(cursor.next(),c);
                var c2 = new Memory(c,k2,v2);
                e0 = cursor.next(); c = c2; more = true; continue;
            } else if (x==id_define) { // @
		trace("--> define branch");
                var k2 = cursor.next();
                var v2 = evaluateInContext(cursor.next(),c);
                var code = evaluateInContext(k2,c);
                //c.add(code,v2);
                //return 1;
                return new CosDefine(code,v2);
            } else if (x==id_if) { // if
		trace("--> if branch");
                // Not really needed now that we have meta-lambda "??"
                var choice = evaluateInContext(cursor.next(),c);

                if (choice!=0) {
                    e0 = cursor.next(); more = true; continue;
		    trace("if branch: " + e0);
                } else {
                    cursor.next();
                    e0 = cursor.next(); more = true; continue;
                }
            } else {
                try {
                    var open = true;

		    trace("--> open branch: x = \"" + x + "\"");

                    var x0 : Dynamic = x;
                    var len = cursor.length();

                    for (i in 0...len) {
                        if (i>0) {
                            if (x==1) {
                                open = true;
                            }
                            var v = cursor.next();
                            if (open) {
                                x = evaluateInContext(v,c);
                            } else {
                                if (Std.is(x,CosFunction)) {
                                    // Currently only used for META functions.
                                    // So: we skip
                                    x = x.fn(function(x) { return evaluateInContext(v,c); });
                                } else {
                                    x = x(evaluateInContext(v,c));
                                }
                            }
                        }
                        if (open) {
			    var strx : String = cast x;
			    trace("if(open) branch: \"" + strx + "\"");
                            if (Std.is(x,Int)||Std.is(x,BigInteger)) {
                                var j : Int = cast x;
				var strx : String = cast x; // TODO: for debug
				trace("int branch in open: \"" + strx + "\"");
				trace("getting x from mem");
                                x = c.get(j);
                                if (len>0) {
                                    if (x == null) {
                                        trace("Problem with " + j + " (" + vocab.reverse(j) + ")");
                                    }
                                }
                                open = false;
                            } else if (Std.is(x,String)) {
                                var j : String = cast x;
				trace("string branch in open: " + x);
				trace("getting x from mem");
                                x = c.get(j);
				trace("x = \"" + x + "\"");

                                if (len>0) {
                                    if (x == null) {
                                        trace("Symbol '" + j + "' unrecognized");
                                    }
                                }
                                open = false;

                            } else if (Std.is(x,BitString)) {
                                // binary string
                                var bs : BitString = cast x;
                                var str : String = x.txt;
                                var u : BigInteger = BigInteger.ofInt(0);
                                var two : BigInteger = BigInteger.ofInt(2);
                                for (j in 0...str.length) {
                                    u = u.mul(two);
                                    if (str.charAt(j) == ':') u = u.add(BigInteger.ONE);
                                }
                                x = u;
                                open = false;
                            } else if (Std.is(x,CosDefine)) {
                                if (!c_is_private) {
                                    c = new Memory(c);
                                    c_is_private = true;
                                }
                                applyDefine(x,c);
                            } else {
				trace("something other found in open branch");
                                open = false;
                            }
                        }
                    }
                } catch(e : Dynamic) {
                    trace("Problem evaluating " + Parse.deconsify(e0));
                    throw(e);
                }
		trace("--> returning for " + Parse.deconsify(e0) + " ->> \"" + x + "\"");
                return x;
            }
        } while (more);
        return null;
    }

    public function applyDefine(e: Dynamic, mem: Memory) : Bool {
        if (!Std.is(e,CosDefine)) return false;
        var def : CosDefine = e;
        mem.add(def.k,def.v);
        return true;
    }

    public function evaluateExpression(e: Dynamic) : Dynamic {
        var r = evaluateInContext(e,mem); // TODO: check!
	var strr : String = cast r;
	//trace("eval expr1: " + strr);
        if (applyDefine(r,mem)) r = 1;
	//trace("eval expr2: " + strr);
        return r;
    }

    public function evaluateLine(str: String) : Dynamic {
        
	trace("original string: " + str);
	trace("test preprocessing: " + Parse.preprocessString(str));
	    
	var lst = Parse.stringToList(str,vocab);
        if (lst==null) return null;

	trace("evaluate line1: " + lst);

        //Parse.encodeSymbols(lst,vocab); // TODO: why is encodeSymbols called here?

	trace("evaluate line2: " + lst);

        Parse.removeSlashMarker(lst);

	trace("evaluate line3: " + lst);

        lst = Parse.consify(lst);

	trace("evaluate line4: " + lst);

        if (id_translate!=-1) {
            var translate = mem.get(id_translate);
            if (translate!=null) {
                lst = translate(lst);
            }
        }
        var lst2 = Parse.deconsify(lst);

	trace("evaluate line5: " + lst2 + " " + lst);

        var v = evaluateExpression(lst); // TODO: check! 

	trace("eval line v = " + v);

	trace("evaluate line6: \"" + v + "\"");

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
	trace("codifyLine");
        Parse.encodeSymbols(lst,vocab); // rewrite numbers into bitcodes?
	trace("list after encodeSymbols");
	trace(lst);
	trace("return codified list");
        return Parse.codify(lst);
    }

    public function nestedLine(str: String) : Dynamic {
        var lst = Parse.stringToList(str,vocab);
	trace("nl1: " + lst);
        Parse.encodeSymbols(lst,null); // TODO: is that necessary?
	trace("nl2: " + lst);
        Parse.recoverList(lst);
	trace("nl3: " + lst);
        return lst;
    }

    public function new() {
        mem = new Memory(null);
        vocab = new Vocab();
        id_lambda = vocab.get("?"); 
        id_lambda0 = vocab.get("??");
        id_define = vocab.get("@"); 
        id_if = vocab.get("if"); 
        id_assign = vocab.get("assign"); 
        id_translate = -1;
    }

    static private function isBi(x:Dynamic) : Bool {
        return Std.is(x,BigInteger);
    }

    static private function isBi2(x:Dynamic,y:Dynamic) : Bool {
        return Std.is(x,BigInteger)||Std.is(y,BigInteger);
    }

    static private function bi(x:Dynamic) : BigInteger {
        if (Std.is(x,BigInteger)) return x;
        return BigInteger.ofInt(x);
    }


    public function getVocab() : Vocab {
        return vocab;
    }

    public function applyOldOrder() {
        mem = new Memory(null);
        vocab.clear();
        vocab.check("intro",0);
        // need to free up "1" -- order will
        // be evaporating soon in any case.
        vocab.check("true",1); // this is what I needed to insert.
        vocab.check("<",2); // was 1
        vocab.check("=",3); // was 2
        vocab.check(">",4); // was 3
        vocab.check("not",5); // was 4
        vocab.check("and",6); // was 5
        vocab.check("or",7);  // was 6
        
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
        vocab.check("demo",36); // was 7

        mem.add(vocab.get("intro"), function(x){ return 1; });
        addStdMin();
        evaluateLine("@ 1 1");
        evaluateLine("@ true 1");
        evaluateLine("@ not | ? 0 | if $0 0 1");
        evaluateLine("@ and | ? 0 | ? 1 | if $0 $1 0");
        evaluateLine("@ or | ? 0 | ? 1 | if $0 1 $1");
        mem.add(vocab.get("make-cell"), function(x){ return { data: x }; } );
        mem.add(vocab.get("get!"), function(x){ 
                return x.data; 
            } );
        mem.add(vocab.get("set!"), function(x){ return function(y) { 
                    x.data = y; 
                    return 1; 
                }; } );
        mem.add(vocab.get("number?"), function(x){ return Std.is(x,Int)||Std.is(x,BigInteger); } );
        mem.add(vocab.get("symbol?"), function(x){ return Std.is(x,String); } );
        mem.add(vocab.get("single?"), function(x){ return Std.is(x,Int)||Std.is(x,BigInteger)||Std.is(x,String)||Std.is(x,BitString); } );
        mem.add(vocab.get("translate"), function(x){ 
                if (Std.is(x,Int)||Std.is(x,BigInteger)||Std.is(x,String)||Std.is(x,BitString)) return x;
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
        mem.add(vocab.get("div"), function(x:Dynamic){ 
                return function(y:Dynamic) : Dynamic { 
                    if (isBi2(x,y)) return bi(x).div(bi(y));
                    return Std.int(x/y); 
                }}
            );
        mem.add(vocab.get("demo"), function(x:Dynamic) {
                return x;
            });

        // Transition vocabulary
        evaluateLine("@ is:int $number?");
        evaluateLine("@ unary-v | ? v | ? x | if (= $x 0) $v (unary-v | + $v 1)");
        evaluateLine("@ unary | unary-v 0");
        // inefficient
        evaluateLine("@ has-divisor-within | ? top | ? x | if (< $top 2) 0 | if (= $x | * $top | div $x $top) 1 | has-divisor-within (- $top 1) $x");
        evaluateLine("@ is:prime | ? x | if (< $x 2) 0 | not | has-divisor-within (- $x 1) $x");
        // very very inefficient!        
        evaluateLine("@ has-square-divisor-within | ? top | ? x | if (< $top 0) 0 | if (= $x | * $top $top) 1 | has-square-divisor-within (- $top 1) $x");
        evaluateLine("@ is:square | ? x | has-square-divisor-within $x $x");

        // meta-lambda-function
        id_lambda0 = vocab.get("??");
    }

    public function addStdMin() {
        mem.add(vocab.get("+"), 
                function(x:Dynamic){ return function(y:Dynamic):Dynamic{ 
                        if (isBi2(x,y)) return bi(x).add(bi(y));
                        return x+y; 
                    }});
        mem.add(vocab.get("-"), 
                function(x:Dynamic){ return function(y:Dynamic):Dynamic{ 
                        if (isBi2(x,y)) return bi(x).sub(bi(y));
                        return x-y; 
                    }});
        mem.add(vocab.get("="), 
                function(x:Dynamic){ return function(y:Dynamic):Dynamic{ 
                        if (isBi2(x,y)) return (bi(x).compare(bi(y))==0)?1:0;
                        return (x==y)?1:0; 
                    }});
        mem.add(vocab.get("*"), 
                function(x:Dynamic){ return function(y:Dynamic):Dynamic{ 
                        if (isBi2(x,y)) return bi(x).mul(bi(y));
                        return x*y; 
                    }});
        mem.add(vocab.get("<"), function(x){ return function(y){ 
                    if (isBi2(x,y)) return (bi(x).compare(bi(y))<0)?1:0;
                    return (x<y)?1:0; 
                }});
        mem.add(vocab.get(">"), function(x){ return function(y){ 
                    if (isBi2(x,y)) return (bi(x).compare(bi(y))>0)?1:0;
                    return (x>y)?1:0; 
                }});
        mem.add(vocab.get("pure"), function(v:Dynamic) {
                if (v) {
                    return function(x:Dynamic) { return function(y:Dynamic) { return x; }};
                } else {
                    return function(x:Dynamic) { return function(y:Dynamic) { return y; }};
                }
            });
        //evaluateLine("@ if | ? v | (pure $v) (? x | ?? y $x) (?? x | ? y $y)");
        evaluateLine("@ eval | ? x | x 1"); // this line is problematic TODO: debug
    }
    
    public function addStd() {
        addStdMin();
        evaluateLine("@ not | ? x | if $x 0 1");
        evaluateLine("@ and | ? x | ? y | if $x $y 0");
        evaluateLine("@ or | ? x | ? y | if $x 1 $y");
    }

    public function addPrimer(primer: Dynamic) {
        mem.add(vocab.get("primer"), Parse.consify(Parse.integrate(primer)));
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

    static function dummy() {
        var v = new ManuscriptStyle();
    }
}
