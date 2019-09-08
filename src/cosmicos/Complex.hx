// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

@:expose
class Complex  {
    public var re:Float;
	public var im:Float;
	
	public function new(re: Float = 0, im: Float = 0)  {
		this.re = re;
		this.im = im;
	}
	
	public function toString() {
		return "[" + re + ", " + im + "]";
	}
	
	inline public function clone() {
		return new Complex(re, im);
	}

    public function mul(alt: Complex) {
        return new Complex(re * alt.re - im * alt.im,  re * alt.im + alt.re * im);
    }
	
	public inline function equals(c2:Complex) {
		return floatEquals(c2.re, re) && floatEquals(c2.im, im);
    }
		
	static public function floatEquals(lhs:Float, rhs:Float) {
        return Math.abs(lhs - rhs) < 0.00000001;
    }
}
