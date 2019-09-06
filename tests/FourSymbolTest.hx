// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class FourSymbolTest extends haxe.unit.TestCase {

    public function testBasic() {
        var state = new cosmicos.State();
        state.useIntVocab();
        var eval = new cosmicos.Evaluate(state);
        eval.applyOldOrder();
        eval.addStdMin();
        var vocab = eval.getVocab();
        var codec = new cosmicos.ChainCodec([
                                             new cosmicos.ParseCodec(vocab),
                                             new cosmicos.NormalizeCodec(vocab),
                                             new cosmicos.FourSymbolCodec(vocab),
                                             ]);
        var tests: Array<Array<Dynamic>> = [
                                            ["+ 1 | * 2 3;", 7],
                                            ["assign x 2 | + 2 | * (x) 3;", 8],
                                            ["assign x 2 | + 3 | * $x 3;", 9],
                                            ["intro foo;", 1],
                                            ["= (unary 1 0) (unary 1 0)", 1],
                                            ["= 1 1", 1],
                                            ["+ (:::) 1", 8],
                                            ["= 5 | + (:.) (::)", 1],
                                            ["+ 0 | + (::::) (:...:)", 32],
                                            ["< 10 | + (:.........................:) (::::::::::::::::::::::::::::::::)", 1],
                                            ];

        for (item in tests) {
            var input = item[0];
            var output = item[1];
            var statement = new cosmicos.Statement(input);
            codec.encode(statement);
            codec.decode(statement);
            var result = eval.evaluateLine(statement.content[0]);
            assertEquals(output, result);
        }
    }
}
