// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package cosmicos;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;

class Constants {
	public inline static var DIGITS_BASE10 : String = "0123456789";
	public inline static var DIGITS_HEXU : String = "0123456789ABCDEF";
	public inline static var DIGITS_HEXL : String = "0123456789abcdef";
	public inline static var DIGITS_OCTAL : String = "01234567";
	public inline static var DIGITS_BN : String = "0123456789abcdefghijklmnopqrstuvwxyz";
	public inline static var DIGITS_BASE64 : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

	public inline static var PROTO_HTTP : String = "http://";
	public inline static var PROTO_HTTPS : String = "http://";
	public inline static var PROTO_FILE : String = "file://";
	public inline static var PROTO_FTP : String = "ftp://";
	public inline static var PROTO_RTMP : String = "rtmp://";
}

/*
 * Copyright (c) 2009, The Caffeine-hx project contributors
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

#if neko
typedef Int32 = I32;
#else
typedef Int32 = Int;
#end

/**
* Static methods for cross platform use of 32 bit Int. All methods are inline,
* so there is no performance penalty.
*
* The Int32 typedef wraps either an I32 in neko, or Int on all other platforms.
* In general, do not define variables or functions typed as I32, use the
* Int32 typedef instead. This allows for native operations without having to
* call the I32 functions.
*
* @author		Russell Weir
**/
class I32 {
	#if neko
	public static var ZERO : Int32;
	public static var ONE : Int32;
	/** 0xFF **/
	public static var BYTE_MASK : Int32;
	#else
	public static inline var ZERO : Int32 = 0;
	public static inline var ONE : Int32 = 1;
	/** 0xFF **/
	public static inline var BYTE_MASK : Int32 = 0xFF;
	#end

	/**
	* Returns byte 4 (highest byte) from the 32 bit int.
	* This is equivalent to v >>> 24 (which is the same as v >> 24 & 0xFF)
	*/
	public static inline function B4(v : Int32) : Int
	{
		return toInt(ushr(v,24));
	}

	/**
	* Returns byte 3 (second highest byte) from the 32 bit int.
	* This is equivalent to v >>> 16 & 0xFF
	*/
	public static inline function B3(v : Int32) : Int
	{
		return toInt(and(ushr(v,16), ofInt(0xFF)));
	}

	/**
	* Returns byte 2 (second lowest byte) from the 32 bit int.
	* This is equivalent to v >>> 8 & 0xFF
	*/
	public static inline function B2(v : Int32) : Int
	{
		return toInt(and(ushr(v,8), ofInt(0xFF)));
	}

	/**
	* Returns byte 1 (lowest byte) from the 32 bit int.
	* This is equivalent to v & 0xFF
	*/
	public static inline function B1(v : Int32) : Int
	{
		return toInt(and(v, ofInt(0xFF)));
	}

	/**
	* Absolute value
	**/
	public static inline function abs(v : Int32) : Int32
	{
		#if neko
		if(compare(ofInt(0), v) > 0)
			return(neg(v));
		else
			return v;
		#else
		return Std.int(Math.abs(v));
		#end
	}

	/**
	* Returns a + b
	*/
	public static inline function add(a : Int32, b : Int32) : Int32
	{
		return #if neko untyped __i32__add(a,b) #else a + b #end;
	}

	/**
	* Extracts an alpha value (high byte) from an ARGB color. An
	* alias for B4()
	*/
	public static inline function alphaFromArgb(v : Int32) : Int
	{
		return B4(v);
	}

	/**
	* Returns a & b
	*/
	public static inline function and(a : Int32, b : Int32) : Int32
	{
		return #if neko untyped __i32__and(a,b) #else a & b #end;
	}

	/**
	*	Encode a 32 bit int to String in base [radix].
	*
	*	@param v Integer to convert
	*	@param radix Number base to convert to, from 2-32
	*	@return String representation of the number in the given base.
	**/
	public static function baseEncode(v : Int32, radix : Int) : String
	{
		if(radix < 2 || radix > 36)
			throw "radix out of range";
		var sb = "";
		var av : Int32 = abs(v);
		var radix32 = ofInt(radix);
		while(true) {
			var r32 = mod(av, radix32);
			sb = Constants.DIGITS_BN.charAt(toInt(r32)) + sb;
			av = div(sub(av,r32), radix32);
			if(eq(av, ZERO))
				break;
		}
		if(lt(v, ZERO))
			return "-" + sb;
		return sb;
	}

	/**
	* Returns ~v
	*/
	public static inline function complement( v : Int32 ) : Int32 {
		return
			#if neko
				untyped __i32__complement(a);
			#else
				~v;
			#end
	}

	/**
	* Returns 0 if a == b, >0 if a > b, and <0 if a < b
	*/
	public static inline function compare( a : Int32, b : Int32 ) : Int {
		return
			#if neko
				untyped __i32__compare(a,b);
			#else
				cast a - b;
			#end
	}


	/**
	* Returns integer division a / b
	*/
	public static inline function div(a : Int32, b : Int32) : Int32
	{
		return #if neko untyped __i32__div(a,b) #else Std.int(a / b) #end;
	}

	/**
	* Encode an Int32 to a big endian string.
	**/
	public static function encodeBE(i : Int32) : Bytes
	{
		var b = Bytes.alloc(4);
		b.set(0, untyped B4(i));
		b.set(1, untyped B3(i));
		b.set(2, untyped B2(i));
		b.set(3, untyped B1(i));
		return b;
	}

	/**
	* Encode an Int32 to a little endian string. Lowest byte is first in string so
	* 0xA0B0C0D0 encodes to [D0,C0,B0,A0]
	**/
	public static function encodeLE(i : Int32) : Bytes
	{
		var b = Bytes.alloc(4);
		b.set(0, untyped B1(i));
		b.set(1, untyped B2(i));
		b.set(2, untyped B3(i));
		b.set(3, untyped B4(i));
		return b;
	}

	/**
	* Decode 4 big endian encoded bytes to a 32 bit integer.
	**/
	public static function decodeBE( s : Bytes, ?pos : Int ) : Int32
	{
		if(pos == null)
			pos = 0;
		var b0 = ofInt(s.get(pos+3));
		var b1 = ofInt(s.get(pos+2));
		var b2 = ofInt(s.get(pos+1));
		var b3 = ofInt(s.get(pos));
		b1 = shl(b1, 8);
		b2 = shl(b2, 16);
		b3 = shl(b3, 24);
		var a = add(b0, b1);
		a = add(a, b2);
		a = add(a, b3);
		return a;
	}

	/**
	* Decode 4 little endian encoded bytes to a 32 bit integer.
	**/
	public static function decodeLE( s : Bytes, ?pos : Int ) : Int32
	{
		if(pos == null)
			pos = 0;
		var b0 = ofInt(s.get(pos));
		var b1 = ofInt(s.get(pos+1));
		var b2 = ofInt(s.get(pos+2));
		var b3 = ofInt(s.get(pos+3));
		b1 = shl(b1, 8);
		b2 = shl(b2, 16);
		b3 = shl(b3, 24);
		var a = add(b0, b1);
		a = add(a, b2);
		a = add(a, b3);
		return a;
	}


	/**
	*	Returns true if a == b
	**/
	public static inline function eq(a:Int32, b:Int32) : Bool
	{
		return
			#if neko
				(compare(a,b) == 0) ? true : false;
			#else
				(a == b);
			#end
	}

	/**
	*	Returns true if a > b
	**/
	public static inline function gt(a:Int32, b:Int32)
	{
		return
			#if neko
				(compare(a,b) > 0) ? true : false;
			#else
				(a > b);
			#end
	}

	/**
	*	Returns true if a >= b
	**/
	public static inline function gteq(a:Int32, b:Int32)
	{
		return
			#if neko
				(compare(a,b) >= 0) ? true : false;
			#else
				(a >= b);
			#end
	}

	/**
	*	Returns true if a < b
	**/
	public static inline function lt(a:Int32, b:Int32) : Bool
	{
		return
			#if neko
				(compare(a,b) < 0) ? true : false;
			#else
				(a < b);
			#end
	}

	/**
	*	Returns true if a <= b
	**/
	public static inline function lteq(a:Int32, b:Int32)
	{
		return
			#if neko
				(compare(a,b) <= 0) ? true : false;
			#else
				(a <= b);
			#end
	}

	/**
	*  Create an Int32 from a high word and a low word
	*/
	public static inline function make( high : Int, low : Int ) : Int32 {
		return
			#if neko
				add(shl(cast high,16),cast low);
			#else
				(high << 16) + low;
			#end
	}

#if neko
	/**
	* Create a neko array of Int32 suitable for passing to ndlls.
	*
	* @param a Array of Int32 type.
	* @return Neko array
	**/
	public static function mkNekoArray( a : Array<Int32> ) : Dynamic {
		if( a == null )
			return null;
		untyped {
			var r = __dollar__amake(a.length);
			var i = 0;
			while( i < a.length ) {
				r[i] = a[i];
				i += 1;
			}
			return r;
		}
	}
#end

	/**
	* Makes a color from an alpha value (0-255) and a 3 byte rgb value
	*/
	public static function makeColor( alpha:Int, rgb:Int) : Int32 {
		#if neko
			var a = shl(ofInt(alpha), 24);
			var c = and(ofInt(rgb), ofInt(0xFFFFFF));
			return or(a, c);
		#else
			return alpha << 24 | (rgb & 0xFFFFFF);
		#end
	}

	/**
	* Returns a % b
	*/
	public static inline function mod(a : Int32, b : Int32) : Int32
	{
		return #if neko untyped __i32__mod(a,b) #else a % b #end;
	}

	/**
	* Returns a * b
	*/
	public static inline function mul(a : Int32, b : Int32) : Int32
	{
		return #if neko untyped __i32__mul(a,b) #else a * b #end;
	}

	/**
	* Negates v, returns -v
	*/
	public static inline function neg(v : Int32) : Int32
	{
		return #if neko untyped __i32__neg(v) #else -v #end;
	}

	/**
	* Creates an Int32 from a haxe Int type
	*/
	public static inline function ofInt(v:Int) : Int32
	{
		return #if neko untyped __i32__new(v) #else v #end;
	}

	/**
	* Returns a | b
	*/
	public static inline function or(a : Int32, b : Int32) : Int32
	{
		return #if neko untyped __i32__or(a,b) #else a | b #end;
	}

	/**
	* Convert an array of 32bit integers to a big endian buffer.
	*
	* @param l Array of Int32 types
	* @return Bytes big endian encoded.
	**/
	public static function packBE(l : Array<Int32>) : Bytes
	{
		var sb = new BytesBuffer();
		for(i in 0...l.length) {
			sb.addByte( B4(l[i]) );
			sb.addByte( B3(l[i]) );
			sb.addByte( B2(l[i]) );
			sb.addByte( B1(l[i]) );
		}
		return sb.getBytes();
	}

	/**
	* Convert an array of 32bit integers to a little endian buffer.
	*
	* @param l Array of Int32 types
	* @return Bytes little endian encoded.
	**/
	public static function packLE(l : Array<Int32>) : Bytes
	{
		var sb = new BytesBuffer();
		for(i in 0...l.length) {
			sb.addByte( B1(l[i]) );
			sb.addByte( B2(l[i]) );
			sb.addByte( B3(l[i]) );
			sb.addByte( B4(l[i]) );
		}
		return sb.getBytes();
	}

	/**
	* Returns the lower 3 bytes of an Int32, most commonly used
	* to extract an RGB value from ARGB color
	*/
	public static inline function rgbFromArgb(v : Int32) : Int
	{
		return
			#if neko
				toInt(and(v, ofInt(0xFFFFFF)));
			#else
				v & 0xFFFFFF;
			#end
	}

	/**
	* Returns a - b
	*/
	public static inline function sub(a : Int32, b : Int32) : Int32
	{
		return #if neko untyped __i32__sub(a,b) #else a - b #end;
	}

	/**
	* Returns v << bits
	*/
	public static inline function shl(v : Int32, bits:Int) : Int32
	{
		return #if neko untyped __i32__shl(v,bits) #else v << bits #end;
	}

	/**
	* Returns v >> bits (signed shift)
	*/
	public static inline function shr(v : Int32, bits:Int) : Int32
	{
		return #if neko untyped __i32__shr(v,bits) #else v >> bits #end;
	}

	/**
	* Returns an exploded color value from the Int32
	*/
	public static inline function toColor(v : Int32) : {alpha:Int,color:Int}
	{
		return {
			alpha : B4(v),
			color : rgbFromArgb(v)
		};
	}

	/**
	* Safely converts an Int32 to Float. In neko, there
	* is no possibility of overflow
	*/
	public static inline function toFloat(v:Int32) : Float
	{
		#if neko
		var high : Int = toInt(ushr(v, 16));
		var low : Int = toInt(and(v, ofInt(0xFFFF)));
		return (high * 0x10000) + (low * 1.0);
		#else
		return v * 1.0;
		#end
	}

	/**
	* Creates a haxe Int from an Int32
	*
	* @throws String Overflow in neko only if 32 bits are required.
	**/
	public static inline function toInt(v : Int32) : Int
	{
		return
			#if neko
				try untyped __i32__to_int(v) catch( e : Dynamic ) throw "Overflow " + v;
			#elseif flash9
				cast v;
			#else
				((cast v) & 0xFFFFFFFF);
			#end
	}

	/**
	* On platforms where there is a native 32 bit int, this will
	* cast an Int32 array properly without overflows thrown.
	*
	* @throws String Overflow in neko only if 32 bits are required.
	**/
	public static inline function toNativeArray(v : Array<Int32>) : Array<Int> {
		#if neko
			var a = new Array<Int>();
			for(i in v)
				a.push(toInt(i));
			return a;
		#else
			return cast v;
		#end
	}

	/**
	* Convert a buffer containing 32bit integers to an array of ints.
	* If the buffer length is not a multiple of 4, an exception is thrown
	**/
	public static function unpackLE(s : Bytes) : Array<Int32>
	{
		if(s == null || s.length == 0)
			return new Array();
		if(s.length % 4 != 0)
			throw "Buffer not multiple of 4 bytes";

		var a = new Array<Int32>();
		var pos = 0;
		var i = 0;
		var len = s.length;
		while(pos < len) {
			a[i] = decodeLE( s, pos );
			pos += 4;
			i++;
		}
		return a;
	}

	/**
	* Convert a buffer containing 32bit integers to an array of ints.
	* If the buffer length is not a multiple of 4, an exception is thrown
	**/
	public static function unpackBE(s : Bytes) : Array<Int32>
	{
		if(s == null || s.length == 0)
			return new Array();
		if(s.length % 4 != 0)
			throw "Buffer not multiple of 4 bytes";

		var a = new Array();
		var pos = 0;
		var i = 0;
		while(pos < s.length) {
			a[i] = decodeBE( s, pos );
			pos += 4;
			i++;
		}
		return a;
	}

	/**
	* Returns v >>> bits (unsigned shift)
	*/
	public static inline function ushr(v : Int32, bits:Int) : Int32
	{
		return #if neko untyped __i32__ushr(v,bits) #else v >>> bits #end;
	}

	/**
	* Returns a ^ b
	*/
	public static inline function xor(a : Int32, b : Int32) : Int32
	{
		return #if neko untyped __i32__xor(a,b) #else a ^ b #end;
	}

	public static function intToHex(j:Int)
	{
		var sb = new StringBuf();
		var i : Int = 8;
		while(i-- > 0) {
			var v : Int = (j>>>(i*4)) & 0xf;
			sb.add(StringTools.hex(v).toLowerCase());
		}
		return sb.toString();
	}

	public static function int32ToHex(j:Int32)
	{
		var sb = new StringBuf();
		var i : Int = 8;
		var f = I32.ofInt(0xf);
		while(i-- > 0) {
			var v : Int = I32.toInt(I32.and(I32.ushr(j,(i*4)), f));
			sb.add(StringTools.hex(v).toLowerCase());
		}
		return sb.toString();
	}

	#if neko
	static function __init__() untyped {
		__i32__new = chx.Lib.load("std","int32_new",1);
		__i32__to_int = chx.Lib.load("std","int32_to_int",1);
		__i32__add = chx.Lib.load("std","int32_add",2);
		__i32__sub = chx.Lib.load("std","int32_sub",2);
		__i32__mul = chx.Lib.load("std","int32_mul",2);
		__i32__div = chx.Lib.load("std","int32_div",2);
		__i32__mod = chx.Lib.load("std","int32_mod",2);
		__i32__shl = chx.Lib.load("std","int32_shl",2);
		__i32__shr = chx.Lib.load("std","int32_shr",2);
		__i32__ushr = chx.Lib.load("std","int32_ushr",2);
		__i32__and = chx.Lib.load("std","int32_and",2);
		__i32__or = chx.Lib.load("std","int32_or",2);
		__i32__xor = chx.Lib.load("std","int32_xor",2);
		__i32__neg = chx.Lib.load("std","int32_neg",1);
		__i32__complement = chx.Lib.load("std","int32_complement",1);
		__i32__compare = chx.Lib.load("std","int32_compare",2);

		ZERO = untyped __i32__new(0);
		ONE = untyped __i32__new(1);
		BYTE_MASK = untyped __i32__new(0xFF);
	}
	#end

}
