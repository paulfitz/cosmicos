// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class EvaluateTest extends haxe.unit.TestCase {

    public function testBasic() {
        var state = new cosmicos.State();
        var vocab = state.getVocab();
        var mem = state.getMemory();
        var codec = new cosmicos.ChainCodec([
                                             new cosmicos.ParseCodec(vocab),
                                             new cosmicos.NormalizeCodec(vocab),
                                             new cosmicos.UnflattenCodec(),
                                             new cosmicos.TranslateCodec(state),
                                             new cosmicos.EvaluateCodec(state)
                                             ]);
        var statement = new cosmicos.Statement("+ 1 | * 2 3;");
        codec.encode(statement);
        assertEquals(7, statement.content[0]);
    }

    public function testEvaluateAndEncode() {
        var state = new cosmicos.State();
        state.useIntVocab();
        var vocab = state.getVocab();
        var normalize = new cosmicos.ChainCodec([
                                                 new cosmicos.ParseCodec(vocab),
                                                 new cosmicos.NormalizeCodec(vocab)
                                                 ]);
        var coding = new cosmicos.FourSymbolCodec(vocab);
        var evaluate = new cosmicos.ChainCodec([
                                                new cosmicos.UnflattenCodec(),
                                                new cosmicos.TranslateCodec(state),
                                                new cosmicos.EvaluateCodec(state)
                                                ]);

        var statement = new cosmicos.Statement("+ 1 | * 2 3;");
        normalize.encode(statement);
        coding.encode(statement);

        var coded = statement.copy().content[0];

        coding.decode(statement);
        evaluate.encode(statement);
        var result = statement.content[0];

        assertEquals(7, result);
        for (i in 0...coded.length) {
            var ch = coded.charAt(i);
            assertTrue(ch >= '0' && ch <= '3');
        }
    }
}
