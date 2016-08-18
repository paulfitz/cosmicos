// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class FourSymbolTest extends haxe.unit.TestCase {

    public function testBasic() {
        var state = new cosmicos.State();
        state.useIntVocab();
        var eval = new cosmicos.Evaluate(state);
        eval.addStdMin();
        eval.applyOldOrder();
        var vocab = eval.getVocab();
        var codec = new cosmicos.ChainCodec([
                                             new cosmicos.ParseCodec(vocab),
                                             new cosmicos.NormalizeCodec(vocab),
                                             new cosmicos.FourSymbolCodec(vocab),
                                             ]);
        var statement = new cosmicos.Statement("+ 1 | * 2 3;");
        codec.encode(statement);
        codec.decode(statement);
        var result = eval.evaluateLine(statement.content[0]);
        assertEquals(7, result);
    }
}
