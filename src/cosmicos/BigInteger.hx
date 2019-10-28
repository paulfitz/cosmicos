// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

// hacked to remove some unneeded functions

/*
 * Copyright (c) 2008, The Caffeine-hx project contributors
 * Original author : Russell Weir
 * Contributors: Mark Winterhalder
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE CAFFEINE-HX PROJECT CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE CAFFEINE-HX PROJECT CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Derived from javascript implementation Copyright (c) 2005 Tom Wu
 * Some derivation from AS3 implementation Copyright (c) 2007 Henri Torgemane
 */

import haxe.io.BytesData;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import cosmicos.I32;

#if neko
enum HndBI {
}
#elseif useOpenSSL
typedef HndBI = Dynamic;
#else
//import math.reduction.ModularReduction;
//import math.reduction.Barrett;
//import math.reduction.Classic;
//import math.reduction.Montgomery;
#end


class BigInteger {
#if (neko || useOpenSSL)
	private var _hnd : HndBI;
	private static var op_and 		: Int = 1;
	private static var op_andnot 	: Int = 2;
	private static var op_or 		: Int = 3;
	private static var op_xor 		: Int = 4;
#else
	/** number of chunks **/
	public var t(default,null) : Int;
	/** sign **/
	public var sign(default,null) : Int;
	/** data chunks **/
	public var chunks(default,null) : Array<Int>; // chunks
	public var am : Int->Int->BigInteger->Int->Int->Int->Int; // am function
#end

	public function new() {
		if(BI_RC == null || BI_RC.length == 0)
			initBiRc();
		if(BI_RM.length == 0)
			throw("BI_RM not initialized");
		#if (neko || useOpenSSL)
			Assert.isNotNull(bi_new);
			_hnd = bi_new();
		#else
			chunks = new Array<Int>();
			#if js
				switch(defaultAm) {
				case 1: am = am1;
				case 2: am = am2;
				case 3: am = am3;
				default: { throw "am error"; null;}
				}
			#else
				am = am2;
			#end
		#end

/*
		if(byInt != null) fromInt(byInt);
		else if( str != null && radix == null) {
			ofString(str,256).copyTo(this);
		}
*/
	}

/*
	// (protected) alternate constructor
	function fromNumber(a,b,c) {
		if("number" == typeof b) {
			// new BigInteger(int,int,RNG)
			if(a < 2) fromInt(1);
			else {
				fromNumber(a,c);
				if(!testBit(a-1))	// force MSB set
					bitwiseTo(ONE.shl(a-1),op_or,this);
				if(isEven()) dAddOffset(1,0); // force odd
				while(!isProbablePrime(b)) {
					dAddOffset(2,0);
					if(bitLength() > a) 	subTo(ONE.shl(a-1),this);
				}
			}
		}

	}
*/

	//////////////////////////////////////////////////////////////
	//                 Conversion methods                       //
	//////////////////////////////////////////////////////////////
	private function fromInt(x : Int) : Void {
		#if (neko || useOpenSSL)
			_hnd = bi_from_int(_hnd, x);
		#else
			t = 1;
			chunks[0] = 0;
			sign = (x<0)?-1:0;
			if (x>0) {
				chunks[0] = x;
			} else if (x<-1) {
				chunks[0] = x+DV;
			} else {
				t = 0;
			}
		#end
	}

	/**
		Set from an integer value. If x is less than -DV, the integer will
		be parsed through fromString.
	**/
	public function fromInt32(x : Int32) : Void {
		#if (neko || useOpenSSL)
			_hnd = bi_from_int32(_hnd, x);
		#else
			fromInt(x);
		#end
	}

	private function toInt() : Int {
		#if (neko || useOpenSSL)
			return bi_to_int(_hnd);
		#else
			if(sign < 0) {
				if(t == 1) return chunks[0]-DV;
				else if(t == 0) return -1;
			}
			else if(t == 1) return chunks[0];
			else if(t == 0) return 0;
			// assumes 16 < DB < 32
			return ((chunks[1]&((1<<(32-DB))-1))<<DB)|chunks[0];
		#end
	}

	/**
		Will return the integer value. If the number of bits in the native
		int does not support the bitlength of this BigInteger, unpredictable
		values will occur.
	**/
	public function toInt32() : Int32 {
		#if (neko || useOpenSSL)
			return bi_to_int32(_hnd);
		#else
			return toInt();
		#end
	}

	/**
	 * convert to bigendian Int array
	 * @deprecated Use toBytes
	 **
	public function toIntArray() : Array<Int> {
		#if (neko || useOpenSSL)
			var i = toRadix(256);
			var a = new Array<Int>();
			for(x in 0...i.length) {
				a.push(i.get(x));
			}
			return a;
		#else
			var i:Int = t;
			var r = new Array();
			r[0] = (sign == 0)?0:0x80;
			var p:Int = DB-(i*DB)%8;
			var d:Int;
			var k:Int = 0;
			if(i-- > 0) {
				if(p < DB && (d = chunks[i]>>p) != (sign&DM)>>p) {
					r[k] = (d|(sign<<(DB-p)) & 0xff);
					k++;
				}
				while(i >= 0) {
					if(p < 8) {
						d = (chunks[i]&((1<<p)-1))<<(8-p);
						--i;
						d |= chunks[i]>>(p+=DB-8);
					}
					else {
						d = (chunks[i]>>(p-=8))&0xff;
						if(p <= 0) { p += DB; --i; }
					}
					if((d&0x80) != 0) d |= -256;
					if(k == 0 && (sign&0x80) != (d&0x80)) ++k;
					if(k > 0 || d != sign) { r[k] = d&0xff; k++; }
				}
			}
			return r;
		#end
	}
	**/

	//////////////////////////////////////////////////////////////
	//            String conversion methods                     //
	//////////////////////////////////////////////////////////////
	/**
		Return a base 10 string
	**/
	public function toString() : String {
		return toRadix(10);
	}

	/**
		Return a hex string
	**/
	public function toHex() : String {
		return toRadix(16);
	}

	/**
	 * Return signed bigendian Bytes.
	 **/
	public function toBytes() : Bytes {
		#if neko
			return Bytes.ofData(cast bi_to_mpi(_hnd));
		#elseif useOpenSSL
			return Bytes.ofStringData(bi_to_mpi(_hnd));
		#else
			var i:Int = t;
			var r:Array<Int> = new Array();
			r[0] = sign;
			var p:Int = DB-(i*DB)%8;
			var d:Int;
			var k:Int=0;
			if (i-->0) {
				if (p<DB && (d=chunks[i]>>p)!=(sign&DM)>>p) {
					r[k] = d|(sign<<(DB-p));
					k++;
				}
				while (i>=0) {
					if(p < 8) {
						d = (chunks[i]&((1<<p)-1))<<(8-p);
						--i;
						d |= chunks[i]>>(p+=DB-8);
					} else {
						d = (chunks[i]>>(p-=8))&0xff;
						if (p<=0) {
							p += DB;
							--i;
						}
					}
					if ((d&0x80)!=0) d |=-256;
					if (k==0 && (sign&0x80) != (d&0x80)) ++k;
					if (k>0 || d!=sign) { r[k] = d; k++; }
				}
			}
			var bb = new BytesBuffer();
			for(i in 0...r.length) {
				bb.addByte(r[i]);
			}
			return bb.getBytes();
		#end
	}

	/**
	* Returns a bigendian bytes with no sign
	**/
	public function toBytesUnsigned():Bytes {
		#if neko
			return Bytes.ofData(cast bi_to_bin(_hnd));
		#elseif useOpenSSL
			return Bytes.ofStringData(bi_to_bin(_hnd));
		#else
			var bb:BytesBuffer = new BytesBuffer();
			var k:Int = 8;
			var km:Int = (1<<8)-1;
			var d:Int = 0;
			var i:Int = t;
			var p:Int = DB-(i*DB)%k;
			var m:Bool = false;
			var c:Int = 0;
			if (i-->0) {
					if (p<DB && (d=chunks[i]>>p)>0) {
							m = true;
							bb.addByte(d);
							c++;
					}
					while (i >= 0) {
							if (p<k) {
									d = (chunks[i]&((1<<p)-1))<<(k-p);
									d|= chunks[--i]>>(p+=DB-k);
							} else {
									d = (chunks[i]>>(p-=k))&km;
									if (p<=0) {
											p += DB;
											--i;
									}
							}
							if (d>0) {
									m = true;
							}
							if (m) {
									bb.addByte(d);
									c++;
							}
					}
			}
			return bb.getBytes();
		#end
	}

	/**
	 * Convert to base 10 or 16 (2 through 36 in flash or JS)
	 * @param b Base to encode to
	 * @returns signed string
	 **/
	public function toRadix(b : Int=10) : String {
		if(b < 2 || b > 36) {
			throw "invalid base for conversion";
		}
		if(sigNum() == 0) return "0";
		#if (neko || useOpenSSL)
			switch(b) {
			case 10: return new String(bi_to_decimal(_hnd));
			case 16: return new String(bi_to_hex(_hnd)).toLowerCase();
			//case 256: return new String(bi_to_mpi(_hnd));
			}
			throw "conversion to base "+b+" not yet supported";
		#else
			var cs: Int = Math.floor(0.6931471805599453*DB/Math.log(b));
			var a:Int = Std.int(Math.pow(b,cs));
			var d:BigInteger = nbv(a);
			var y:BigInteger = nbi();
			var z:BigInteger = nbi();
			var r:String = "";
			divRemTo(d,y,z);
			while(y.sigNum() > 0) {
				r = I32.baseEncode(
						I32.add(
							I32.ofInt(a),
							z.toInt32()
						), b).substr(1) + r;
				y.divRemTo(d,y,z);
			}
			return I32.baseEncode(z.toInt32(), b) + r;
		#end
	}

	/**
	* Return bytes representation in given radix.
	* This function handles radix values 2, 4, 8, 32.
	**
	public function toRadix(b : Int) : String {
		/*
		* convert to radix string, handles any base 2-36
		*
		if((b < 2 || b > 36) && b != 256) {
			throw("invalid base for conversion");
		}
		#if (neko || useOpenSSL)
			switch(b) {
			case 10: return Bytes.ofData(cast bi_to_decimal(_hnd));
			case 16: return Bytes.ofString(new String(bi_to_hex(_hnd)).toLowerCase() );
			case 256: return Bytes.ofData(cast bi_to_mpi(_hnd));
			}
			throw "conversion to base "+b+" not yet supported";
		#else
			var rv = new BytesBuffer();
			if(sign < 0) {
				if( b != 256 )
					rv.addByte("-".charCodeAt(0));
				rv.add(neg().toRadix(b));
				return rv.getBytes();
			}
			var k;
			if(b == 16) k = 4;
			else if(b == 256) {
				var ba = toIntArray();
				for(x in 0...ba.length) {
					rv.addByte(ba[x]);
				}
				return rv.getBytes();
			}
			else if(b == 8) k = 3;
			else if(b == 2) k = 1;
			else if(b == 32) k = 5;
			else if(b == 4) k = 2;
			else return toRadixExt(this, b);
			var km = (1<<k)-1, d, m = false, i = t;
			var r = new BytesBuffer();
			var p = DB-(i*DB)%k;
			if(i-- > 0) {
				if(p < DB && (d = chunks[i]>>p) > 0) {
					m = true;
					r = new BytesBuffer();
					r.addByte(int2charCode(d));
				}
				while(i >= 0) {
				if(p < k) {
					d = (chunks[i]&((1<<p)-1))<<(k-p);
					--i;
					d |= chunks[i]>>(p+=DB-k);
				}
				else {
					d = (chunks[i]>>(p-=k))&km;
					if(p <= 0) { p += DB; --i; }
				}
				if(d > 0) m = true;
				if(m) r.addByte( int2charCode(d) );
				}
			}
			return m ? r.getBytes() : zero;
		#end
	}*/


	//////////////////////////////////////////////////////////////
	//                    Math methods                          //
	//////////////////////////////////////////////////////////////
	/** Absolute value **/
	public function abs() : BigInteger {
		#if (neko || useOpenSSL)
			var h = bi_abs(_hnd);
			return hndToBigInt(h);
		#else
			return (sign<0)?neg():this;
		#end
	}

	/** this + a **/
	public function add(a:BigInteger) : BigInteger
	{
		var r = nbi(); addTo(a,r); return r;
	}

	/**
		<pre>return + if this > a, - if this < a, 0 if equal</pre>
	**/
	public function compare(a:BigInteger) : Int {
		#if (neko || useOpenSSL)
			return bi_cmp(this._hnd, a._hnd);
		#else
			var r = sign-a.sign;
			if(r != 0) return r;
			var i:Int = t;
			r = i-a.t;
			if(r != 0) return r;
			while(--i >= 0) {
				r=chunks[i]-a.chunks[i];
				if(r != 0) return r;
			}
			return 0;
		#end
	}

	/** this / a **/
	public function div(a) : BigInteger
	{ var r = nbi(); divRemTo(a,r,null); return r; }

	/** <pre>[this/a,this%a]</pre> **/
	public function divideAndRemainder(a:BigInteger) : Array<BigInteger> {
		var q = nbi();
		var r = nbi();
		divRemTo(a,q,r);
		return [q,r];
	}

	/** this == a **/
	public function eq(a:BigInteger) : Bool {
		return compare(a) == 0;
	}

	/** true if this is even **/
	public function isEven() :Bool {
		#if (neko || useOpenSSL)
			var i : Int = bi_is_odd(this._hnd);
			return (i==0)?true:false;
		#else
			return ((t>0)?(chunks[0]&1):sign) == 0;
		#end
	}

	/**	Return the biggest of this and a **/
	public function max(a:BigInteger) : BigInteger {
		return (compare(a)>0)?this:a;
	}

	/**	Return the smallest of this and a **/
	public function min(a:BigInteger) : BigInteger {
		return (compare(a)<0)?this:a;
	}

	/** Modulus division bn % bn **/
	public function mod(a:BigInteger) : BigInteger {
		#if (neko || useOpenSSL)
			return hndToBigInt(bi_mod(this._hnd, a._hnd));
		#else
			var r:BigInteger = nbi();
			abs().divRemTo(a,null,r);
			if(sign < 0 && r.compare(ZERO) > 0) a.subTo(r,r);
			return r;
		#end
	}

	/** <pre>this % n, n < 2^26</pre> **/
	public function modInt(n : Int) : Int {
		#if (neko || useOpenSSL)
			var b = BigInteger.ofInt(n);
			return hndToBigInt(bi_mod(this._hnd, b._hnd)).toInt();
		#else
			if(n <= 0) return 0;
			var d:Int = DV%n;
			var r:Int = (sign<0)?n-1:0;
			if(t > 0)
				if(d == 0) r = chunks[0]%n;
				else {
					var i = t-1;
					while( i >= 0) {
						r = (d*r+chunks[i])%n;
						--i;
					}
				}
			return r;
		#end
	}

	/**
		1/this % m (HAC 14.61)
	**/
	public function modInverse(m:BigInteger) : BigInteger {
		#if (neko || useOpenSSL)
			return hndToBigInt(bi_mod_inverse(this._hnd, m._hnd));
		#else
			var ac = m.isEven();
			if((isEven() && ac) || m.sigNum() == 0) return ZERO;
			var u:BigInteger = m.clone();
			var v:BigInteger = clone();
			var a:BigInteger = nbv(1);
			var b:BigInteger = nbv(0);
			var c:BigInteger = nbv(0);
			var d:BigInteger = nbv(1);
			while(u.sigNum() != 0) {
				while(u.isEven()) {
					u.rShiftTo(1,u);
					if(ac) {
						if(!a.isEven() || !b.isEven()) {
							a.addTo(this,a);
							b.subTo(m,b);
						}
						a.rShiftTo(1,a);
					}
					else if(!b.isEven())
						b.subTo(m,b);
					b.rShiftTo(1,b);
				}
				while(v.isEven()) {
					v.rShiftTo(1,v);
					if(ac) {
						if(!c.isEven() || !d.isEven()) {
							c.addTo(this,c);
							d.subTo(m,d);
						}
						c.rShiftTo(1,c);
					}
					else if(!d.isEven())
						d.subTo(m,d);
					d.rShiftTo(1,d);
				}
				if(u.compare(v) >= 0) {
					u.subTo(v,u);
					if(ac) a.subTo(c,a);
					b.subTo(d,b);
				}
				else {
					v.subTo(u,v);
					if(ac) c.subTo(a,c);
					d.subTo(b,d);
				}
			}
			if(v.compare(ONE) != 0) return ZERO;
			if(d.compare(m) >= 0) return d.sub(m);
			if(d.sigNum() < 0) d.addTo(m,d); else return d;
			//if(d.sigNum() < 0) return d.add(m); else return d;
			return d;
		#end
	}

	/** this * a **/
	public function mul(a:BigInteger) : BigInteger
	{ var r = nbi(); multiplyTo(a,r); return r; }

	/**
		-this
	**/
	public function neg() : BigInteger {
		var r = nbi();
		ZERO.subTo(this,r);
		return r;
	}

	/** this % a **/
	public function remainder(a:BigInteger) : BigInteger
	{ var r = nbi(); divRemTo(a,null,r); return r; }

	/** this - a **/
	public function sub(a:BigInteger) : BigInteger
	{ var r = nbi(); subTo(a,r); return r; }


	//////////////////////////////////////////////////////////////
	//                  Bitwise Operators                       //
	//////////////////////////////////////////////////////////////
	/** this &amp; a **/
	public function and(a:BigInteger) : BigInteger {
		var r = nbi();
		bitwiseTo(a,op_and,r);
		return r;
	}

	/** this &amp; ~a **/
	public function andNot(a:BigInteger) : BigInteger {
		var r = nbi();
		bitwiseTo(a,op_andnot,r);
		return r;
	}

	/** return number of set bits **/
	public function bitCount() : Int {
		#if (neko || useOpenSSL)
			return bi_bits_set(_hnd);
		#else
			var r = 0, x = sign&DM;
			for(i in 0...t) r += cbit(chunks[i]^x);
			return r;
		#end
	}

	/**
		return the number of bits in "this"
	**/
	public function bitLength() : Int {
		#if (neko || useOpenSSL)
			return bi_bitlength(_hnd);
		#else
			if(t <= 0) return 0;
			return DB*(t-1)+nbits(chunks[t-1]^(sign&DM));
		#end
	}

	/** ~this **/
	public function complement() : BigInteger {
		#if (neko || useOpenSSL)
			var h = bi_not(_hnd);
			return hndToBigInt(h);
		#else
			var r:BigInteger = nbi();
			for(i in 0...t) r.chunks[i] = DM&~chunks[i];
			r.t = t;
			r.sign = ~sign;
			return r;
		#end
	}

	/** <pre>this & ~(1<<n)</pre> **/
	public function clearBit(n) : BigInteger {
		#if (neko || useOpenSSL)
			var bi:BigInteger = clone();
			bi_clear_bit(bi._hnd, n);
			return bi;
		#else
			return changeBit(n,op_andnot);
		#end
	}

	/** <pre>this ^ (1<<n)</pre> **/
	public function flipBit(n) : BigInteger {
		#if (neko || useOpenSSL)
			var bi:BigInteger = nbi();
			bi_copy(bi._hnd, cast _hnd);
			bi_flip_bit(bi._hnd, n);
			return bi;
		#else
			return changeBit(n,op_xor);
		#end
	}

	/** returns index of lowest 1-bit (or -1 if none) **/
	public function getLowestSetBit() : Int {
		#if (neko || useOpenSSL)
			return bi_lowest_bit_set(_hnd);
		#else
			for(i in 0...t)
				if(chunks[i] != 0) return i*DB+lbit(chunks[i]);
			if(sign < 0) return t*DB;
			return -1;
		#end
	}

	#if !(cpp)
	/**
	 * ~this. Alias for complement
	 * @deprecated Can not use in cpp currently, as 'not' is not treated as reserved word
	 **/
	public function not():BigInteger {
		return complement();
	}
	#end

	/** this | a **/
	public function or(a:BigInteger) : BigInteger {
		var r = nbi(); bitwiseTo(a,op_or,r); return r;
	}

	/** <pre>this | (1<<n)</pre> **/
	public function setBit(n:Int) : BigInteger {
		#if (neko || useOpenSSL)
			var r : BigInteger = clone();
			bi_set_bit(r._hnd, n);
			return r;
		#else
			return changeBit(n,op_or);
		#end
	}

	/**
		<pre>this << n</pre>
	**/
	public function shl(n : Int) : BigInteger {
		var r:BigInteger = nbi();
		if(n < 0) rShiftTo(-n,r); else lShiftTo(n,r);
		return r;
	}

	/**
		<pre>this >> n</pre>
	**/
	public function shr(n : Int) : BigInteger {
		var r:BigInteger = nbi();
		if(n < 0) lShiftTo(-n,r); else rShiftTo(n,r);
		return r;
	}

	/** <pre>true iff nth bit is set</pre> **/
	public function testBit(n:Int) : Bool {
		#if (neko || useOpenSSL)
			return bi_test_bit(_hnd, n);
		#else
			var j = Math.floor(n/DB);
			if(j >= t) return(sign!=0);
			return((chunks[j]&(1<<(n%DB)))!=0);
		#end
	}

	/** this ^ a **/
	public function xor(a:BigInteger) : BigInteger {
		var r:BigInteger = nbi();
		bitwiseTo(a,op_xor,r);
		return r;
	}


	//////////////////////////////////////////////////////////////
	//             'Result To' Math methods                     //
	// These methods take 'this', perform math function with    //
	// 'a', and store the result in 'r'                         //
	//////////////////////////////////////////////////////////////
	/** r = this + a **/
	public function addTo(a:BigInteger,r:BigInteger) : Void {
		#if (neko || useOpenSSL)
			bi_add_to(_hnd, a._hnd, r._hnd);
			return;
		#else
			var i:Int = 0;
			var c:Int = 0;
			var m:Int = Std.int(Math.min(a.t,t));
			while(i < m) {
				c += chunks[i]+a.chunks[i];
				r.chunks[i] = c&DM;
				i++;
				c >>= DB;
			}
			if(a.t < t) {
				c += a.sign;
				while(i < t) {
					c += chunks[i];
					r.chunks[i] = c&DM;
					i++;
					c >>= DB;
				}
				c += sign;
			}
			else {
				c += sign;
				while(i < a.t) {
					c += a.chunks[i];
					r.chunks[i] = c&DM;
					i++;
					c >>= DB;
				}
				c += a.sign;
			}
			r.sign = (c<0)?-1:0;
			if(c > 0) { r.chunks[i] = c; i++; }
			else if(c < -1) { r.chunks[i] = DV+c; i++; }
			r.t = i;
			r.clamp();
		#end
	}

	/** copy this to r **/
	public function copyTo(r:BigInteger) : Void {
		#if (neko || useOpenSSL)
			bi_copy(r._hnd, cast _hnd);
		#else
			for(i in 0...chunks.length)
				r.chunks[i] = chunks[i];
			r.t = t;
			r.sign = sign;
		#end
	}

	/**
		divide this by m, quotient and remainder to q, r (HAC 14.20)
		<pre>r != q, this != m.  q or r may be null.</pre>
	**/
	public function divRemTo(m:BigInteger, q:Null<BigInteger>, ?r:Null<BigInteger>) : Void
	{
		#if (neko || useOpenSSL)
			if(r == null) r = nbi();
			if(q == null) q = nbi();
			bi_div_rem_to(this._hnd, m._hnd, q._hnd, r._hnd);
			return;
		#else
			var pm:BigInteger = m.abs();
			if(pm.t <= 0) return;
			var pt:BigInteger = abs();
			if(pt.t < pm.t) {
				if(q != null) q.fromInt(0);
				if(r != null) copyTo(r);
				return;
			}
			if(r == null) r = nbi();
		#if flash9
			var y : Dynamic = nbi(); // Weird VerifyError workaround
			//var y : BigInteger = nbi();
		#else
			var y : BigInteger = nbi();
		#end
			var ts:Int = sign;
			var ms:Int = m.sign;

			var nsh: Int = DB-nbits(pm.chunks[pm.t-1]);	// normalize modulus
			if(nsh > 0) {
				pt.lShiftTo(nsh,r);
				pm.lShiftTo(nsh,y);
			}
			else {
				pt.copyTo(r);
				pm.copyTo(y);
			}

			var ys: Int = y.t;
			var y0: Int = y.chunks[ys-1];
			if(y0 == 0) return;
			var yt:Float = (y0*1.0)*((1<<F1)*1.0) + ((ys>1) ? ((y.chunks[ys-2]>>F2)*1.0) : 0.0);
			var d1:Float = FV/yt;
			var d2:Float = ((1<<F1)*1.0)/yt;
			var e:Float = ((1<<F2)*1.0);
			var i:Int = r.t;
			var j:Int = i-ys;
			var t:BigInteger = (q==null)?nbi():q;

			/** <pre> t = this << n*DB </pre> **/
			y.dlShiftTo(j,t);
			if(r.compare(t) >= 0) {
				r.chunks[r.t] = 1;
				r.t++;
				r.subTo(t,r);
			}

			ONE.dlShiftTo(ys,t);
			t.subTo(y,y);	// "negative" y so we can replace sub with am later
			while(y.t < ys) { y.chunks[y.t] = 0; y.t++; }
			while(--j >= 0) {
				// Estimate quotient digit
				var qd:Int;
				// --i;
				if(r.chunks[--i] == y0)
					qd = DM;
				else
					qd = Math.floor((r.chunks[i]*1.0) * d1 + ((r.chunks[i-1]*1.0) + e) *d2);
				r.chunks[i] += y.am(0,qd,r,j,0,ys);
				if(r.chunks[i] < qd) {
					y.dlShiftTo(j,t);
					r.subTo(t,r);
					while(r.chunks[i] < --qd) { r.subTo(t,r); }
				}
			}

			if(q != null) {
				r.drShiftTo(ys,q);
				if(ts != ms) ZERO.subTo(q,q);
			}
			r.t = ys;
			r.clamp();

			if(nsh > 0) r.rShiftTo(nsh,r);	// Denormalize remainder
			if(ts < 0) ZERO.subTo(r,r);
		#end
	}

#if !(neko || useOpenSSL)
	/**
		(protected) r = lower n words of "this * a", <pre>a.t <= n</pre>
		"this" should be the larger one if appropriate.
	**/
	public function multiplyLowerTo(a:BigInteger,n : Int,r:BigInteger) : Void {
		var i : Int = Std.int(Math.min(t+a.t,n));
		r.sign = 0; // assumes a,this >= 0
		r.t = i;
		while(i > 0) { --i; r.chunks[i] = 0; }
		var j : Int = r.t - t;
		while(i < j) {
			r.chunks[i+t] = am(0,a.chunks[i],r,i,0,t);
			++i;
		}
		j = Std.int(Math.min(a.t,n));
		while(i < j) {
			am(0,a.chunks[i],r,i,0,n-i);
			++i;
		}
		r.clamp();
	}
#end

	/**
		<pre>r = this * a, r != this,a (HAC 14.12)</pre>
		"this" should be the larger one if appropriate.
	**/
	public function multiplyTo(a:BigInteger, r:BigInteger) : Void {
		#if (neko || useOpenSSL)
			var h = bi_mul_to(_hnd, a._hnd, r._hnd);
			return;
		#else
			var x = abs(), y = a.abs();
			var i:Int = x.t;
			r.t = i+y.t;
			while(--i >= 0) r.chunks[i] = 0;
			for( i in 0...y.t ) r.chunks[i+x.t] = x.am(0,y.chunks[i],r,i,0,x.t);
			r.sign = 0;
			r.clamp();
			if(sign != a.sign) ZERO.subTo(r,r);
		#end
	}

#if !(neko || useOpenSSL)
	/**
		(protected) r = "this * a" without lower n words, <pre>n > 0</pre>
		"this" should be the larger one if appropriate.
	**/
	public function multiplyUpperTo(a:BigInteger,n:Int,r:BigInteger) : Void {
		--n;
		var i : Int = r.t = t+a.t-n;
		r.sign = 0; // assumes a,this >= 0
		while(--i >= 0)
			r.chunks[i] = 0;
		i = Std.int(Math.max(n-t,0));
		for(x in i...a.t)
			r.chunks[t+x-n] = am(n-x,a.chunks[x],r,0,0,t+x-n);
		r.clamp();
		r.drShiftTo(1,r);
	}
#end

	/** <pre>r = this^2, r != this (HAC 14.16)</pre> **/
	public function squareTo(r:BigInteger) : Void {
		#if (neko || useOpenSSL)
			bi_sqr_to(_hnd, r._hnd);
			return;
		#else
			if(r == this)
				throw("can not squareTo self");
			var x = abs();
			var i:Int = r.t = 2*x.t;
			while(--i >= 0) r.chunks[i] = 0;
			i = 0;
			while(i < x.t - 1) {
				var c:Int = x.am(i,x.chunks[i],r,2*i,0,1);
				if((r.chunks[i+x.t]+=x.am(i+1,2*x.chunks[i],r,2*i+1,c,x.t-i-1)) >= DV) {
					r.chunks[i+x.t] -= DV;
					r.chunks[i+x.t+1] = 1;
				}
				i++;
			}
			if(r.t > 0) {
				var rv = x.am(i,x.chunks[i],r,2*i,0,1);
				r.chunks[r.t-1] += rv;
			}
			r.sign = 0;
			r.clamp();
		#end
	}

	/** <pre>r = this - a</pre> **/
	public function subTo(a:BigInteger, r:BigInteger) : Void {
		#if (neko || useOpenSSL)
			var h = bi_sub_to(_hnd, a._hnd, r._hnd);
			return;
		#else
			var i: Int = 0;
			var c: Int = 0;
			var m: Int = Std.int(Math.min(a.t,t));
			while(i < m) {
				c += chunks[i]-a.chunks[i];
				r.chunks[i] = c&DM;
				i++;
				c >>= DB;
			}
			if(a.t < t) {
				c -= a.sign;
				while(i < t) {
					c += chunks[i];
					r.chunks[i] = c&DM;
					i++;
					c >>= DB;
				}
				c += sign;
			}
			else {
				c += sign;
				while(i < a.t) {
					c -= a.chunks[i];
					r.chunks[i] = c&DM;
					i++;
					c >>= DB;
				}
				c -= a.sign;
			}
			r.sign = (c<0)?-1:0;
			if(c < -1) { r.chunks[i] = DV+c; i++; }
			else if(c > 0) { r.chunks[i] = c; i++; }
			r.t = i;
			r.clamp();
		#end
	}


	//////////////////////////////////////////////////////////////
	//                    Misc methods                          //
	//////////////////////////////////////////////////////////////
	/** clamp off excess high words **/
#if !(neko || useOpenSSL)
	public function clamp() : Void {
		var c = sign&DM;
		while(t > 0 && chunks[t-1] == c) --t;
	}
#end

	/** Clone a BigInteger **/
	public function clone():BigInteger {
		var r = nbi();
		copyTo(r);
		return r;
	}

	// (public) gcd(this,a) (HAC 14.54)
	public function gcd(a:BigInteger):BigInteger {
		#if (neko || useOpenSSL)
			var h = bi_gcd(_hnd, a._hnd);
			return hndToBigInt(h);
		#else
			var x:BigInteger = (sign<0)?neg():clone();
			var y:BigInteger = (a.sign<0)?a.neg():a.clone();
			if(x.compare(y) < 0) { var t:BigInteger = x; x = y; y = t; }
			var i:Int = x.getLowestSetBit(), g:Int = y.getLowestSetBit();
			if(g < 0) return x;
			if(i < g) g = i;
			if(g > 0) {
				x.rShiftTo(g,x);
				y.rShiftTo(g,y);
			}
			while(x.sigNum() > 0) {
				if((i = x.getLowestSetBit()) > 0) x.rShiftTo(i,x);
				if((i = y.getLowestSetBit()) > 0) y.rShiftTo(i,y);
				if(x.compare(y) >= 0) {
					x.subTo(y,x);
					x.rShiftTo(1,x);
				}
				else {
					y.subTo(x,y);
					y.rShiftTo(1,y);
				}
			}
			if(g > 0) y.lShiftTo(g,y);
			return y;
		#end
	}

	/**
		Pads the chunk buffer to n chunks, left fill with 0.
	**/
#if !(neko || useOpenSSL)
	public function padTo ( n : Int ) : Void {
		while( t < n )	{ chunks[ t ] = 0; t++; }
	}
#end

	/** return value as short (assumes DB &gt;= 16) **/
	public function shortValue() : Int {
		#if (neko || useOpenSSL)
			return toInt() & 0xffff;
		#else
			return (t==0)?sign:(chunks[0]<<16)>>16;
		#end
	}

	/** return value as byte **/
	function byteValue() : Int {
		#if (neko || useOpenSSL)
			return toInt() & 0xff;
		#else
			return (t==0)?sign:(chunks[0]<<24)>>24;
		#end
	}

	/** <pre>0 if this == 0, 1 if this > 0</pre>**/
	public function sigNum() : Int {
		#if (neko || useOpenSSL)
			return bi_signum(_hnd);
		#else
			if(sign < 0) return -1;
			else if(t <= 0 || (t == 1 && chunks[0] <= 0)) return 0;
			else return 1;
		#end
	}


	//////////////////////////////////////////////////////////////
	//        Reduction public methods (move to private)        //
	//////////////////////////////////////////////////////////////
	/**
		<pre>this += n << w words, this >= 0</pre>
	**/
	public function dAddOffset(n : Int, w : Int) :Void {
		#if (neko || useOpenSSL)
			var bi:BigInteger = BigInteger.ofInt(w);
			if(w != 0)
				bi = bi.shl(w*32);
			addTo(bi, this);
		#else
			while(t <= w) { chunks[t] = 0; t++; }
			chunks[w] += n;
			while(chunks[w] >= DV) {
				chunks[w] -= DV;
				if(++w >= t) { chunks[t] = 0; t++; }
				++chunks[w];
			}
		#end
	}

#if !(neko || useOpenSSL)
	/** <pre> r = this << n*DB </pre> **/
	public function dlShiftTo(n : Int, r:BigInteger) :Void {
		if(r == null) return;
		var i = t-1;
		while(i >= 0) {
			r.chunks[i+n] = chunks[i];
			i--;
		}
		i = n-1;
		while(i >= 0) {
			r.chunks[i] = 0;
			i--;
		}
		r.t = t+n;
		r.sign = sign;
	}

	/** <pre>r = this >> n*DB</pre> **/
	public function drShiftTo(n : Int, r:BigInteger) :Void {
		if(r == null) return;
		var i:Int = n;
		while(i < t) {
			r.chunks[i-n] = chunks[i];
			i++;
		}
		r.t = Std.int( Math.max(t-n,0) );
		r.sign = sign;
	}

	/**
		<pre>return "-1/this % 2^DB"; useful for Mont. reduction</pre>
	**/
	// justification:
	//         xy == 1 (mod m)
	//         xy =  1+km
	//   xy(2-xy) = (1+km)(1-km)
	// x[y(2-xy)] = 1-k^2m^2
	// x[y(2-xy)] == 1 (mod m^2)
	// if y is 1/x mod m, then y(2-xy) is 1/x mod m^2
	// should reduce x and y(2-xy) by m^2 at each step to keep size bounded.
	// JS multiply "overflows" differently from C/C++, so care is needed here.
	public function invDigit() : Int {
		if(t < 1) return 0;
		var x:Int = chunks[0];
		if((x&1) == 0) return 0;
		var y:Int = x&3;		// y == 1/x mod 2^2
		y = (y*(2-(x&0xf)*y))&0xf;	// y == 1/x mod 2^4
		y = (y*(2-(x&0xff)*y))&0xff;	// y == 1/x mod 2^8
		y = (y*(2-(((x&0xffff)*y)&0xffff)))&0xffff;	// y == 1/x mod 2^16
		// last step - calculate inverse mod DV directly;
		// assumes 16 < DB <= 32 and assumes ability to handle 48-bit ints
		y = (y*(2-((x*y)%DV))) % DV;		// y == 1/x mod 2^dbits
		// we really want the negative inverse, and -DV < y < DV
		return (y>0)?DV-y:-y;
	}
#end


	//////////////////////////////////////////////////////////////
	//					Private methods							//
	//////////////////////////////////////////////////////////////
	// (protected) r = this op a (bitwise)
#if (neko || useOpenSSL)
	function bitwiseTo(a:BigInteger, op:Int, r:BigInteger) : Void {
		bi_bitwise_to(_hnd, a._hnd, op, r._hnd);
	}
#else
	function bitwiseTo(a:BigInteger, op:Int->Int->Int, r:BigInteger) : Void {

		var f : Int;
		var m : Int = Std.int(Math.min(a.t,t));
		for(i in 0...m) r.chunks[i] = op(chunks[i],a.chunks[i]);
		if(a.t < t) {
			f = a.sign & DM;
			for(i in m...t) r.chunks[i] = op(chunks[i],f);
			r.t = t;
		}
		else {
			f = sign&DM;
			for(i in m...a.t) r.chunks[i] = op(f,a.chunks[i]);
			r.t = a.t;
		}
		r.sign = op(sign,a.sign);
		r.clamp();
	}
#end

#if !(neko || useOpenSSL)
	/** this op (1<<n) 	**/
	function changeBit(n,op) : BigInteger {
		var r = ONE.shl(n);
		bitwiseTo(r,op,r);
		return r;
	}

	/** <pre>return x s.t. r^x < DV</pre> **/
	function chunkSize(r : Int) : Int {
		return Math.floor(0.6931471805599453*DB/Math.log(r));
	}

	/**
		(protected) <pre>this *= n, this >= 0, 1 < n < DV</pre>
	**/
	function dMultiply ( n : Int ) : Void {
		chunks[ t ] = am(0,n-1,this,0,0,t);
		t++;
		clamp();
	}

#end

	//////////////////////////////////////////////////////////////
	//             'Result To' Bitwise methods                  //
	// These methods take 'this', perform bitwise function with //
	// 'a', and store the result in 'r'                         //
	// These are not public, since a lsh of a negative should   //
	// be done as a rsh. Use shl() and shr()                    //
	//////////////////////////////////////////////////////////////
	/** <pre>r = this << n </pre> **/
	function lShiftTo(n:Int, r:BigInteger) : Void {
		#if (neko || useOpenSSL)
			var h = bi_shl_to(_hnd, n, r._hnd);
			return;
		#else
			var bs: Int = n%DB;
			var cbs:Int = DB-bs;
			var bm:Int = (1<<cbs)-1;
			var ds:Int = Math.floor(n/DB), c:Int = (sign<<bs)&DM, i : Int;
		//		for(i = t-1; i >= 0; --i) {
			var i = t-1;
			while( i >= 0 ) {
				r.chunks[i+ds+1] = (chunks[i]>>cbs)|c;
				c = (chunks[i]&bm)<<bs;
				i--;
			}
		//		for(i = ds-1; i >= 0; --i) r.chunks[i] = 0;
			i = ds - 1;
			while( i >= 0 ) { r.chunks[i] = 0; i--; }
			r.chunks[ds] = c;
			r.t = t+ds+1;
			r.sign = sign;
			r.clamp();
		#end
	}

	/** <pre>r = this >> n</pre> **/
	function rShiftTo(n : Int, r:BigInteger) : Void {
		#if (neko || useOpenSSL)
			var h = bi_shr_to(_hnd, n, r._hnd);
			return;
		#else
			r.sign = sign;
			var ds:Int = Math.floor(n/DB);
			if(ds >= t) { r.t = 0; return; }
			var bs:Int = n%DB;
			var cbs:Int = DB-bs;
			var bm:Int = (1<<bs)-1;
			r.chunks[0] = chunks[ds]>>bs;
		//		for(var i = ds+1; i < t; ++i) {
			for( i in (ds + 1)...t ) {
				r.chunks[i-ds-1] |= (chunks[i]&bm)<<cbs;
				r.chunks[i-ds] = chunks[i]>>bs;
			}
			if(bs > 0) r.chunks[t-ds-1] |= (sign&bm)<<cbs;
			r.t = t-ds;
			r.clamp();
		#end
	}

#if !(neko || useOpenSSL)
#if js
	// am1: use a single mult and divide to get the high bits,
	// max digit bits should be 26 because
	// max internal value = 2*dvalue^2-2*dvalue (< 2^53)
	function am1(i:Int,x:Int,w:BigInteger,j:Int,c:Int,n:Int) : Int {
		while(--n >= 0) {
			var v : Int = x*chunks[i]+w.chunks[j]+c;
			i++;
			c = Math.floor(v/0x4000000);
			w.chunks[j] = v&0x3ffffff;
			j++;
		}
		return c;
	}
#end
#if !(neko || useOpenSSL)
	// am: Compute w_j += (x*this_i), propagate carries,
	// c is initial carry, returns final carry.
	// c < 3*dvalue, x < 2*dvalue, this_i < dvalue
	//
	// am2 avoids a big mult-and-extract completely.
	// Max digit bits should be <= 30 because we do bitwise ops
	// on values up to 2*hdvalue^2-hdvalue-1 (< 2^31)
	public function am2(i:Int,x:Int,w:BigInteger,j:Int,c:Int,n:Int) : Int {
		var xl:Int = x&0x7fff;
		var xh:Int = x>>15;
		while(--n >= 0) {
			var l : Int = chunks[i]&0x7fff;
			var h : Int = chunks[i]>>15;
			i++;
			var m : Int = xh*l + h*xl;
			l = xl*l + ((m&0x7fff)<<15)+w.chunks[j]+(c&0x3fffffff);
			c = (l>>>30)+(m>>>15)+xh*h+(c>>>30);
			w.chunks[j] = l&0x3fffffff;
			j++;
		}
		return c;
	}
#end
#if js
	// Alternately, set max digit bits to 28 since some
	// browsers slow down when dealing with 32-bit numbers.
	public function am3(i:Int,x:Int,w:BigInteger,j:Int,c:Int,n:Int) : Int {
		var xl : Int = x&0x3fff;
		var xh : Int = x>>14;
		while(--n >= 0) {
			var l : Int = chunks[i]&0x3fff;
			var h : Int = chunks[i]>>14;
			i++;
			var m : Int = (xh*l) + (h*xl);
			l = (xl*l) + ((m&0x3fff)<<14) + w.chunks[j] + c;
			c = (l>>28) + (m>>14) + (xh*h);
			w.chunks[j] = l&0xfffffff;
			j++;
		}
		return c;
	}
#end
#end

	//////////////////////////////////////////////////////////////
	//                  Static variables                        //
	//////////////////////////////////////////////////////////////

	public static var MAX_RADIX : Int = 36;
	public static var MIN_RADIX : Int = 2;

	//dbits (DB) TODO: assumed to be 16 < DB < 32
	public static var DB : Int; // bits per chunk.
	public static var DM : Int; // bit mask
	public static var DV : Int; // max value in bitsize

	public static var BI_FP : Int;
	public static var FV : Float;
	public static var F1 : Int;
	public static var F2 : Int;

	public static var ZERO(get,null)	: BigInteger;
	public static var ONE(get, null)		: BigInteger;

	// Digit conversions
	#if as3gen public #end static var BI_RM : String;
	#if as3gen public #end static var BI_RC : Array<Int>;

	public static var lowprimes : Array<Int>;
	public static var lplim : Int;
	#if as3gen public #end static var defaultAm : Int; // am function

	//////////////////////////////////////////////////////////////
	//                   Static methods                         //
	//////////////////////////////////////////////////////////////

	static function __init__() {
		// Bits per chunk
		var dbits : Int;
		#if js
            /*
			// JavaScript engine analysis
			var j_lm : Bool;
			untyped {
				var canary : Int = __js__('0xdeadbeefcafe');
				j_lm = ((canary&0xffffff)==0xefcafe);
			}
			var browser: String = untyped window.navigator.appName;
			if(j_lm && (browser == "Microsoft Internet Explorer"))
				dbits = 30;
			else if(j_lm && (browser != "Netscape"))
				dbits = 26;
			else // Mozilla/Netscape seems to prefer
            dbits = 28;
            */
            dbits = 30;
		#else
			dbits = 30;
		#end
		switch(dbits) {
		case 30: defaultAm = 2;
		case 28: defaultAm = 3;
		case 26: defaultAm = 1;
		default: throw "bad dbits value";
		}
		DB = dbits;
		DM = ((1<<DB)-1);
		DV = (1<<DB);
		BI_FP = 52;
		FV = Math.pow(2,BI_FP);
		F1 = BI_FP-DB;
		F2 = 2*DB-BI_FP;
		// TODO: for some reason on flash8, BI_RC was not initializing here
		// properly, so it is double checked in the constructor.
		initBiRc();
		BI_RM = "0123456789abcdefghijklmnopqrstuvwxyz";

		lowprimes = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,241,251,257,263,269,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,367,373,379,383,389,397,401,409,419,421,431,433,439,443,449,457,461,463,467,479,487,491,499,503,509];
		lplim = Std.int((1<<26)/lowprimes[lowprimes.length-1]);

	}

	#if as3gen public #end static function initBiRc() : Void {
		BI_RC = new Array<Int>();
		var rr : Int = "0".charCodeAt(0);
		for(vv in 0...10) {
			BI_RC[rr] = vv;
			rr++;
		}
		rr = "a".charCodeAt(0);
		for(vv in 10...37) {
			BI_RC[rr] = vv;
			rr++;
		}
		rr = "A".charCodeAt(0);
		for(vv in 10...37) {
			BI_RC[rr] = vv;
			rr++;
		}
	}

	/**
		Getter function for static var ZERO
	**/
	static function get_ZERO() : BigInteger {
		return nbv(0);
	}

	/**
		Getter funtion for static var ONE
	**/
	static function get_ONE() : BigInteger {
		return nbv(1);
	}

	//////////////////////////////////////////////////////////////
	//                     Constructors                         //
	//////////////////////////////////////////////////////////////
	/**
		Create a new big integer from the int value i
	**/
	public static function nbv(i : Int) : BigInteger {
		var r = nbi();
		r.fromInt(i);
		return r;
	}

	/**
		return new, unset BigInteger
	**/
	public static function nbi() : BigInteger {
		return new BigInteger();
	}

	/**
	* Construct a BigInteger from a string in a given base. Negative
	* values in base256 are stored as (0x80 << (bytes *8)) | abs().
	* Positive values that have the high bit set should be prefixed
	* with a 0 byte.
	**/
	public static function ofString(s : String, base : Int) : BigInteger {
		#if (neko || useOpenSSL)
			var sn = #if neko Bytes.ofString(s).getData() #else s #end;
			switch(base) {
			case 10: return hndToBigInt(bi_from_decimal(sn));
			case 16: return hndToBigInt(bi_from_hex(sn));
			case 256: return hndToBigInt(bi_from_bin(sn));
			default:
				throw "conversion from base "+base+" not yet supported";
				return null;
			}
		#else
			var me:BigInteger = nbi();
			// convert from radix string
			var fromStringExt = function(s : String, b : Int) : BigInteger {
				me.fromInt(0);
				var cs:Int = Math.floor(0.6931471805599453*DB/Math.log(b));
				var d:Int = Std.int( Math.pow(b,cs) );
				var mi:Bool = false;
				var j:Int = 0;
				var w:Int = 0;
				for(i in 0...s.length) {
					var x = intAt(s,i);
					if(x < 0) {
						if(s.charAt(i) == "-" && me.sign == 0) mi = true;
						continue;
					}
					w = b*w+x;
					if(++j >= cs) {
						me.dMultiply( d );
						me.dAddOffset(w,0);
						j = 0;
						w = 0;
					}
				}
				if(j > 0) {
					me.dMultiply(Std.int( Math.pow(b,j) ));
					me.dAddOffset(w,0);
				}
				if(mi) ZERO.subTo(me,me);
				return me;
			}
			//Bases != [2,4,8,16,32,256] are handled through fromStringExt
			var k : Int;
			if(base == 16) k = 4;
			else if(base == 10) { return fromStringExt(s,base); }
			else if(base == 256) k = 8; // byte array
			else if(base == 8) k = 3;
			else if(base == 2) k = 1;
			else if(base == 32) k = 5;
			else if(base == 4) k = 2;
			else { return fromStringExt(s,base); }
			me.t = 0;
			me.sign = 0;
			var i = s.length, mi = false, sh = 0;
			while(--i >= 0) {
				var x = (k==8)?s.charCodeAt( i )&0xff:intAt(s,i);
				if(x < 0) {
					if(s.charAt(i) == "-") mi = true;
					continue;
				}
				mi = false;
				if(sh == 0) {
					me.chunks[me.t] = x;
					me.t++;
				}
				else if(sh+k > DB) {
					me.chunks[me.t-1] |= (x&((1<<(DB-sh))-1))<<sh;
					me.chunks[me.t] = (x>>(DB-sh));
					me.t++;
				}
				else
					me.chunks[me.t-1] |= x<<sh;
				sh += k;
				if(sh >= DB) sh -= DB;
			}
			if(k == 8 && (s.charCodeAt( 0 )&0x80) != 0) {
				me.sign = -1;
				if(sh > 0) me.chunks[me.t-1] |= ((1<<(DB-sh))-1)<<sh;
			}
			me.clamp();
			if(mi) ZERO.subTo(me,me);
			return me;
		#end
	}

	/**
		Construct a BigInteger from an integer value
	**/
	public static function ofInt(x : Int) : BigInteger {
		var i = nbi();
		i.fromInt(x);
		return i;
	}

	/**
		Construct a BigInteger from an integer value
	**/
	public static function ofInt32(x : Int32) : BigInteger {
		var i = nbi();
		i.fromInt32(x);
		return i;
	}

	/*
		Construct a BigInteger from a ByteString. This is abs() encoded
		just like ofString().
		TODO: Two's complement ByteString handling for ASN1
	*/
	/*
	public static function ofByteString(b : Bytes, base : Int) : BigInteger {
	}
	*/

	/**
	* Construct from a bigendian byte array in base 256. If signed, first byte high bit, if set,
	* indicates a negative number.
	* @param r Base 256 bytes
	* @param unsigned True to treat buffer as an unsigned array
	* @param pos Starting position of start buffer.
	* @param len Length of buffer to use. Set to null to use all remaining
	**/
	public static function ofBytes(r:Bytes, unsigned:Bool, pos:Int=0, len:Null<Int>=null) : BigInteger {
		if(len == null)
			len = r.length - pos;
		if(len == 0)
			return ZERO;
		#if neko
			if(unsigned)
				return hndToBigInt(bi_from_bin(r.sub(pos,len).getData()));
			else
				return hndToBigInt(bi_from_mpi(r.sub(pos,len).getData()));
		#elseif useOpenSSL
			if(unsigned)
				return hndToBigInt(bi_from_bin(r.toString().substr(pos,len)));
			else
				return hndToBigInt(bi_from_mpi(r.toString().substr(pos,len)));
		#else
			var bi : BigInteger = nbi();
			bi.sign = 0;
			bi.t = 0;
			var i:Int = pos+len;
			var sh:Int = 0;
			while (--i >= pos) {
				var x:Int = i < len ? r.get(i)&0xff:0;
				if (sh == 0) {
					bi.chunks[bi.t] = x;
					bi.t++;
				}
				else if (sh+8 > DB) {
					bi.chunks[bi.t-1] |= (x&((1<<(DB-sh))-1))<<sh;
					bi.chunks[bi.t] = x>>(DB-sh);
					bi.t++;
				}
				else {
					bi.chunks[bi.t-1] |= x<<sh;
				}
				sh += 8;
				if (sh >= DB)
					sh -= DB;
			}
			if(!unsigned && (r.get(0) & 0x80) != 0) {
				bi.sign = -1;
				if(sh > 0) bi.chunks[bi.t-1] |= ((1<<(DB-sh))-1)<<sh;
			}
			bi.clamp();
			return bi;
		#end
	}

	/** deprecated
	public static function ofIntArray(a:Array<Int>, ?pos:Int, ?len:Int) {
		if(pos == null)
			pos = 0;
		if(len == null)
			len = a.length - pos;
		if(len == 0)
			return ZERO;
		var start = pos;
		var max:Int = pos+len;
		if(max > a.length) {
			max = a.length;
			len = max - pos;
		}
		var bb = new BytesBuffer();
		while (pos < max) {
			bb.addByte(a[pos]);
			pos++;
		}
		return ofBytes(bb.getBytes(), 0, len);
	}
	**/


	//////////////////////////////////////////////////////////////
	//                  Operator functions                      //
	//////////////////////////////////////////////////////////////
#if !(neko || useOpenSSL)
	public static function op_and(x:Int, y:Int) : Int { return x&y; }
	public static function op_or(x:Int, y:Int) : Int { return x|y; }
	public static function op_xor(x:Int, y:Int) : Int { return x^y; }
	public static function op_andnot(x:Int, y:Int) : Int { return x&(~y); }
#end

	//////////////////////////////////////////////////////////////
	//                Misc Static functions                     //
	//////////////////////////////////////////////////////////////
	/** returns bit length of the integer x **/
	public static function nbits( x : Int ) : Int {
		var r : Int = 1;
		var t : Int;
		if((t=x>>>16) != 0) { x = t; r += 16; }
		if((t=x>>8) != 0) { x = t; r += 8; }
		if((t=x>>4) != 0) { x = t; r += 4; }
		if((t=x>>2) != 0) { x = t; r += 2; }
		if((t=x>>1) != 0) { x = t; r += 1; }
		return r;
	}

	/** return number of 1 bits in x **/
	public static function cbit(x : Int) : Int {
		var r = 0;
		while(x != 0) { x &= x-1; ++r; }
		return r;
	}

	static function intAt(s : String, i: Int) : Int {
		var c : Null<Int> = BI_RC[s.charCodeAt(i)];
		if(c == null) return -1;
		return c;
	}

// 	static function int2char(n: Int) : String {
// 		return BI_RM.charAt(n);
// 	}

	static function int2charCode(n:Int) : Int {
		return BI_RM.charCodeAt(n);
	}

	/** <pre>return index of lowest 1-bit in x, x < 2^31</pre> **/
	static function lbit(x : Int) : Int {
		if(x == 0) return -1;
		var r = 0;
		if((x&0xffff) == 0) { x >>= 16; r += 16; }
		if((x&0xff) == 0) { x >>= 8; r += 8; }
		if((x&0xf) == 0) { x >>= 4; r += 4; }
		if((x&3) == 0) { x >>= 2; r += 2; }
		if((x&1) == 0) ++r;
		return r;
	}

#if !(neko || useOpenSSL)
	static function dumpBi(r:BigInteger) : String {
		var s = "sign: " + Std.string(r.sign);
		s += " t: "+r.t;
		s += Std.string(r.chunks);
		return s;
	}
#end

#if (neko || useOpenSSL)
	static function hndToBigInt(h:HndBI) : BigInteger {
		var rv = BigInteger.nbi();
		rv._hnd = h;
		return rv;
	}

	static function seedRandom(bits:Int, b:math.prng.Random) : Void {
		var len = (bits>>3) + 1;
		var x = Bytes.alloc(len);
		b.nextBytes(x,0,len);
		bi_rand_seed(x.getData());
	}

	private static var bi_new=chx.Lib.load("openssl","bi_new",0);
	private static var destroy_biginteger=chx.Lib.load("openssl","destroy_biginteger",1);
	private static var bi_ZERO=chx.Lib.load("openssl","bi_ZERO",0);
	private static var bi_ONE=chx.Lib.load("openssl","bi_ONE",0);
	private static var bi_copy=chx.Lib.load("openssl","bi_copy",2);
	private static var bi_generate_prime=chx.Lib.load("openssl","bi_generate_prime",2);
	private static var bi_is_prime=chx.Lib.load("openssl","bi_is_prime",3);
	private static var bi_abs=chx.Lib.load("openssl","bi_abs",1);
	private static var bi_add_to=chx.Lib.load("openssl","bi_add_to",3);
	private static var bi_sub_to=chx.Lib.load("openssl","bi_sub_to",3);
	private static var bi_mul_to=chx.Lib.load("openssl","bi_mul_to",3);
	private static var bi_sqr_to=chx.Lib.load("openssl","bi_sqr_to",2);
	private static var bi_div=chx.Lib.load("openssl","bi_div",2);
	private static var bi_div_rem_to=chx.Lib.load("openssl","bi_div_rem_to",4);
	private static var bi_mod=chx.Lib.load("openssl","bi_mod",2);
	private static var bi_mod_exp=chx.Lib.load("openssl","bi_mod_exp",3);
	private static var bi_mod_inverse=chx.Lib.load("openssl","bi_mod_inverse",2);
	private static var bi_pow=chx.Lib.load("openssl","bi_pow",2);
	private static var bi_gcd=chx.Lib.load("openssl","bi_gcd",2);
	private static var bi_signum=chx.Lib.load("openssl","bi_signum",1);
	private static var bi_cmp=chx.Lib.load("openssl","bi_cmp",2);
	private static var bi_ucmp=chx.Lib.load("openssl","bi_ucmp",2);
	private static var bi_is_zero=chx.Lib.load("openssl","bi_is_zero",1);
	private static var bi_is_one=chx.Lib.load("openssl","bi_is_one",1);
	private static var bi_is_odd=chx.Lib.load("openssl","bi_is_odd",1);
	// random
	private static var bi_rand_seed=chx.Lib.load("openssl","bi_rand_seed",1);
	private static var bi_rand=chx.Lib.load("openssl","bi_rand",3);
	private static var bi_pseudo_rand=chx.Lib.load("openssl","bi_pseudo_rand",3);
	// conversion
	private static var bi_to_hex=chx.Lib.load("openssl","bi_to_hex",1);
	private static var bi_from_hex=chx.Lib.load("openssl","bi_from_hex",1);
	private static var bi_to_decimal=chx.Lib.load("openssl","bi_to_decimal",1);
	private static var bi_from_decimal=chx.Lib.load("openssl","bi_from_decimal",1);
	private static var bi_to_bin=chx.Lib.load("openssl","bi_to_bin",1);
	private static var bi_from_bin=chx.Lib.load("openssl","bi_from_bin",1);
	private static var bi_to_mpi=chx.Lib.load("openssl","bi_to_mpi",1);
	private static var bi_from_mpi=chx.Lib.load("openssl","bi_from_mpi",1);
	private static var bi_from_int=chx.Lib.load("openssl","bi_from_int",2);
	private static var bi_from_int32=chx.Lib.load("openssl","bi_from_int32",2);
	private static var bi_to_int=chx.Lib.load("openssl","bi_to_int",1);
	private static var bi_to_int32=chx.Lib.load("openssl","bi_to_int32",1);

	// bitwise
	private static var bi_shl_to=chx.Lib.load("openssl","bi_shl_to",3);
	private static var bi_shr_to=chx.Lib.load("openssl","bi_shr_to",3);
	private static var bi_bitlength=chx.Lib.load("openssl","bi_bitlength",1);
	private static var bi_bytelength=chx.Lib.load("openssl","bi_bytelength",1);
	private static var bi_bits_set=chx.Lib.load("openssl","bi_bits_set",1);
	private static var bi_lowest_bit_set=chx.Lib.load("openssl","bi_lowest_bit_set",1);
	private static var bi_set_bit=chx.Lib.load("openssl","bi_set_bit",2);
	private static var bi_clear_bit=chx.Lib.load("openssl","bi_clear_bit",2);
	private static var bi_flip_bit=chx.Lib.load("openssl","bi_flip_bit",2);
	private static var bi_bitwise_to=chx.Lib.load("openssl","bi_bitwise_to",4);
	private static var bi_not=chx.Lib.load("openssl","bi_not",1);
	private static var bi_test_bit=chx.Lib.load("openssl","bi_test_bit",2);

#end
}

