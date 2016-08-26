// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class UnflattenTest extends haxe.unit.TestCase {
    public function roundTrip(str: String) : String {
        var vocab = new cosmicos.Vocab();
        var codec = new cosmicos.ChainCodec([
                                             new cosmicos.ParseCodec(vocab),
                                             new cosmicos.NormalizeCodec(vocab),
                                             new cosmicos.UnflattenCodec()
                                             ]);
        var statement = new cosmicos.Statement(str);
        codec.encode(statement);
        codec.decode(statement);
        assertEquals(1, statement.content.length);
        return statement.content[0];
    }

    public function assertRoundTrip(str: String) {
        var result = roundTrip(str);
        assertEquals(str, result);
    }

    public function testBasic() {
        var statements : Array<String> = [
                                          "+ 1 1;",
                                          "+ (+ 1 1) 1;",
                                          "+ 1 | + 1 1;",
                                          "+ 1 | + $x $y;",
                                          ];
        for (i in 0...statements.length) {
            assertRoundTrip(statements[i]);
        }
    }

    public function testExtraFlat() {
        var txt = roundTrip("+ 1 (+ 1 1);");
        assertEquals("+ 1 | + 1 1;", txt);
        var txt = roundTrip("+ 1 (+ (x) (y));");
        assertEquals("+ 1 | + $x $y;", txt);
    }
}
