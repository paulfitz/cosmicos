// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Evaluate {
    private var state : State;
    private var config : Config;
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
        do {
            if (Std.is(e0,String)) {
                var str : String = cast e0;
                if (str.length==0 || str.charAt(0) == '1') {
                    return str.length;
                }
                return str;
            }
            if (Std.is(e0,Int)||Std.is(e0,BigInteger)||Std.is(e0,BitString)||
                Std.is(e0,String)) {
                return e0;
            }
            var cursor = new Cursor(e0);
            var x : Dynamic = evaluateInContext(cursor.next(),c);
            if (x==id_lambda) { // ?
                var k2 : Dynamic = evaluateInContext(cursor.next(),c);
                var e2 : Dynamic = cursor.next();
                return function(v) {
                    var c2 = new Memory(c,k2,v);
                    return evaluateInContext(e2,c2);
                };
            } else if (x==id_lambda0) { // ??
                var k2 : Int = evaluateInContext(cursor.next(),c);
                var e2 : Dynamic = cursor.next();
                return new CosFunction(function(v) {
                        var c2 = new Memory(c,k2,v);
                        return evaluateInContext(e2,c2);
                }, true);
            } else if (x==id_assign) { // not super needs
                var k2 : Int = evaluateInContext(cursor.next(),c);
                var v2 : Int = evaluateInContext(cursor.next(),c);
                var c2 = new Memory(c,k2,v2);
                e0 = cursor.next(); c = c2; more = true; continue;
            } else if (x==id_define) { // @
                var k2 = cursor.next();
                var v2 = evaluateInContext(cursor.next(),c);
                var code = evaluateInContext(k2,c);
                //c.add(code,v2);
                //return 1;
                return new CosDefine(code,v2);
            } else if (x==id_if) { // if
                // Not really needed now that we have meta-lambda "??"
                var choice = evaluateInContext(cursor.next(),c);
                if (choice!=0) {
                    e0 = cursor.next(); more = true; continue;
                } else {
                    cursor.next();
                    e0 = cursor.next(); more = true; continue;
                }
            } else {
                try {
                    var open = true;
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
                            if (Std.is(x,Int)||Std.is(x,BigInteger)) {
                                var j : Int = cast x;
                                x = c.get(j);
                                if (len>0) {
                                    if (x == null) {
                                        trace("Problem with " + j + " (" + vocab.reverse(j) + ")");
                                        throw("Problem with " + j + " (" + vocab.reverse(j) + ")");
                                    }
                                }
                                open = false;
                            } else if (Std.is(x,String)) {
                                var j : String = cast x;
                                x = c.get(j);
                                if (len>0) {
                                    if (x == null) {
                                        trace("Symbol '" + j + "' unrecognized");
                                        throw("Symbol '" + j + "' unrecognized");
                                    }
                                }
                                open = false;

                            } else if (Std.is(x,BitString)) {
                                // binary string
                                var bs : BitString = cast x;
                                /*var str : String = x.txt;
                                  var u : BigInteger = BigInteger.ofInt(0);
                                var two : BigInteger = BigInteger.ofInt(2);
                                for (j in 0...str.length) {
                                    u = u.mul(two);
                                    if (str.charAt(j) == ':') u = u.add(BigInteger.ONE);
                                }
                                x = u;
                                */
                                x = bs.asBigInteger();
                                open = false;
                            } else if (Std.is(x,CosDefine)) {
                                if (!c_is_private) {
                                    c = new Memory(c);
                                    c_is_private = true;
                                }
                                applyDefine(x,c);
                            } else {
                                open = false;
                            }
                        }
                    }
                } catch(e : Dynamic) {
                    trace("Problem evaluating " + Cons.deconsify(e0) + " (" + e + ")");
                    throw(e);
                }
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
        var r = evaluateInContext(e,mem);
        if (applyDefine(r,mem)) r = 1;
        return r;
    }

    public function evaluateLine(str: String) : Dynamic {
        var codec = new ChainCodec([
                                    new ParseCodec(vocab),
                                    new NormalizeCodec(vocab),
                                    new UnflattenCodec(),
                                    new TranslateCodec(state)
                                    ]);
        var statement = new Statement(str);
        codec.encode(statement);
        return evaluateExpression(statement.content);
    }

    public function new(state : State = null) {
        if (state == null) state = new State();
        this.state = state;
        mem = state.getMemory();
        vocab = state.getVocab();
        id_lambda = vocab.get("?");
        id_lambda0 = vocab.get("??");
        id_define = vocab.get("@");
        id_if = vocab.get("if");
        id_assign = vocab.get("assign");
        id_translate = -1;
        this.config = state.getConfig();
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

    public function getMemory() : Memory {
        return mem;
    }

    public function getState() : State {
        return state;
    }

    public function explain(name: String, desc: String, ?example: String) {
        vocab.setMeta(name, new VocabMeta(desc, example));
    }

    public function applyOldOrder() {
        if (mem == null) mem = new Memory(null);
        vocab.clear();
        vocab.check("intro",0);
        vocab.check("true",1);
        vocab.check("<",2);
        explain("<", "is one integer less than another", "< 41 42");
        vocab.check("=",3);
        explain("=", "test for integer equality", "= 42 42");
        vocab.check(">",4);
        explain(">", "is one integer greater than another", "> 42 41");
        vocab.check("not",5);
        vocab.check("and",6);
        vocab.check("or",7);
        
        vocab.check("equal",8);
        vocab.check("*",9);
        explain("*", "multiply two integers", "* 2 21");
        vocab.check("+",10);
        explain("+", "add two integers", "+ 22 20");
        vocab.check("-",11);
        explain("+", "subtract one integer from another", "- 44 2");

        id_lambda = vocab.check("?",12);
        explain("?", "create an anonymous function", "? x | - $x 1");
        id_define = vocab.check("define",13);
        // define and @ are fudged together, TODO fix this
        explain("@", "store an expression in memory", "@ dec | ? x | - $x 1");
        id_assign = vocab.check("assign",14);
        id_if = vocab.check("if",15);
        explain("if", "conditional evaluation", "if (> $x 1) (dec $x) $x");
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

        // start using longer codes for early symbols
        vocab.set("is:int", 183);  //0b10110111
        vocab.set("unary", 255);   //0b11111111

        mem.add(vocab.get("intro"), function(x){ return 1; });
        addStdMin();
        evaluateLine("@ 1 1");
        evaluateLine("@ true 1");
        addDefinition("not", "? 0 | if $0 0 1");
        addDefinition("and", "? 0 | ? 1 | if $0 $1 0");
        addDefinition("or", "? 0 | ? 1 | if $0 1 $1");
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
                var len = Cons.car(x);
                if (len==0) return x;
                var current : Dynamic = mem.get(id_translate);
                if (len==1) return Cons.cons(1,current(Cons.cdr(x)));
                var rep = function(r : Dynamic, len : Int, rec : Dynamic) : Dynamic {
                    if (len==2) return Cons.cons(current(Cons.car(r)),
                                                  current(Cons.cdr(r)));
                    return Cons.cons(current(Cons.car(r)),
                                     rec(Cons.cdr(r),len-1,rec));
                }
                return Cons.cons(len,rep(Cons.cdr(x),len,rep));
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
                return Cons.consify(lst);
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
        evaluateLine("@ undefined 999");

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
        evaluateLine("@ eval | ? x | x 1");
    }

    public function addDefinition(name: String, body: String) {
        evaluateLine("@ " + name + " | " + body);
        vocab.setMeta(name, new VocabMeta(body, ""));
    }
    
    public function addStd() {
        addStdMin();
        addDefinition("not", "? x | if $x 0 1");
        addDefinition("and", "? x | ? y | if $x $y 0");
        addDefinition("or", "? x | ? y | if $x 1 $y");
    }

    public function addPrimer(primer: Dynamic) {
        mem.add(vocab.get("primer"), Cons.consify(primer));
    }

    public function examples(): Array<String> {
        return [
                "+ 3 (* 10 2)",
                "+ 3 | * 10 2",
                "+ 3 20",
                "@ square | ? x | * $x $x",
                "square 10",
                "@ factorial | ? n | if (= $n 0) 1 | * $n | factorial (- $n 1)",
                "factorial 5",
                "@ first | ? x | ? y | x",
                "@ second | ? x | ? y | y",
                "@ cons | ? x | ? y | ? f | f $x $y",
                "@ car | ? f | f $first",
                "@ cdr | ? f | f $second",
                "car | cons 10 15",
                "cdr | cons 10 15"];
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
        // make sure classes needed externally don't get pruned
        new ManuscriptStyle();
        new FourSymbolCodec(null);
        new EvaluateCodec(null);
        new PreprocessCodec(null);
    }
}
