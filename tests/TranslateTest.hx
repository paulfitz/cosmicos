// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class TranslateTest extends haxe.unit.TestCase {

    public function testBasic() {
        var eval = new cosmicos.Evaluate();
        eval.addStdMin();
        eval.applyOldOrder();
        var vocab = eval.getVocab();
        var state = eval.getState();
        var codec = new cosmicos.ChainCodec([
                                             new cosmicos.ParseCodec(vocab),
                                             new cosmicos.NormalizeCodec(vocab),
                                             new cosmicos.UnflattenCodec(),
                                             new cosmicos.TranslateCodec(state)
                                             ]);
        var statement = new cosmicos.Statement("= 32 64;");
        codec.encode(statement);
        codec.decode(statement);
        assertEquals("= 32 64;", statement.content[0]);
        eval.evaluateLine("define base-translate $translate;");
        eval.evaluateLine("define translate | ? x | if (= $x 32) 64 (base-translate $x);");
        statement = new cosmicos.Statement("= 32 64;");
        codec.encode(statement);
        codec.decode(statement);
        assertEquals("= 64 64;", statement.content[0]);
    }
}
