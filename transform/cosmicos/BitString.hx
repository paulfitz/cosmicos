// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

// temporary workaround to support old lesson, this should be going away soon
@:expose
class BitString {
    public var txt : String;
    public function new(txt: String) {
        this.txt = txt;
    }

    public function asBigInteger() : BigInteger {
        var u : BigInteger = BigInteger.ofInt(0);
        var two : BigInteger = BigInteger.ofInt(2);
        for (j in 0...txt.length) {
            u = u.mul(two);
            if (txt.charAt(j) == ':') u = u.add(BigInteger.ONE);
        }
        return u;
    }

    public function small() : Bool {
        return txt.length < 15;
    }

    public function asInteger() : Dynamic {
        if (!small()) return asBigInteger();
        var u : Int = 0;
        for (j in 0...txt.length) {
            u *= 2;
            if (txt.charAt(j) == ':') u++;
        }
        return u;
    }
}
