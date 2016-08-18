// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class ParseTest extends haxe.unit.TestCase {
    public function roundTrip(str: String) {
        var vocab = new cosmicos.Vocab();
        var codec : cosmicos.Codec = new cosmicos.ParseCodec(vocab);
        var statement = new cosmicos.Statement(str);
        codec.encode(statement);
        codec.decode(statement);
        assertEquals(1, statement.content.length);
        assertEquals(str, statement.content[0]);
    }

    public function testBasic() {
        var statements : Array<String> = [
                                          "+ 1 1;",
                                          "+ 1 (* 2 | + $y $x);",
                                          "+ 1 (* (+ 1 | - 2 1) | + $y $x);",
                                          ];
        for (i in 0...statements.length) {
            roundTrip(statements[i]);
        }
    }
}
