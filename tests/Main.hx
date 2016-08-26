// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class Main {

    public function new() {
    }

    public function body() : Int {
        var r = new haxe.unit.TestRunner();
        var cases = [
                     new ParseTest(),
                     new NormalizeTest(),
                     new UnflattenTest(),
                     new TranslateTest(),
                     new FourSymbolTest(),
                     new EvaluateTest(),
                     ];

#if js
        var args = untyped __js__("process.argv.slice(2)");
#else
        var args = Sys.args;  // this might be out by one, not tested
#end
        var filter = args[0];
        for (c in cases) {
            var name = Type.getClassName(Type.getClass(c));
            if (filter=="" || name.indexOf(filter)>=0) {
                r.add(c);
            }
        }
        var ok = r.run();
        if (!ok) {
            return 1;
        }
        return 0;
    }

    static public function main() {
        var main = new Main();
        var result = main.body();
#if js
       untyped __js__("process.exit(result)");
#else
       Sys.exit(result);
#end
    }
}
