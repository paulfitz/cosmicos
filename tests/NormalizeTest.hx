// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class NormalizeTest extends haxe.unit.TestCase {
    public function roundTrip(str: String) : String {
        var vocab = new cosmicos.Vocab();
        var parse : cosmicos.Codec = new cosmicos.ParseCodec(vocab);
        var norm : cosmicos.Codec = new cosmicos.NormalizeCodec(vocab);
        var statement = new cosmicos.Statement(str);
        parse.encode(statement);
        norm.encode(statement);
        norm.decode(statement);
        parse.decode(statement);
        assertEquals(1, statement.content.length);
        return statement.content[0];
    }

    public function assertRoundTrip(str: String) {
        var result = roundTrip(str);
        assertEquals(str, result);
    }

    public function testBasic() {
        var statements : Array<String> = [
                                          "+ :..: 1;",
                                          "demo \"test\" 1;",
                                          "@ foo 1;"
                                          ];
        for (i in 0...statements.length) {
            assertRoundTrip(statements[i]);
        }
    }

    public function testDefine() {
        var txt = roundTrip("define foo 1;");
        assertEquals("@ foo 1;", txt);
    }
}
