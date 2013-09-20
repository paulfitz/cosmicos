(function () { "use strict";
var $estr = function() { return js.Boot.__string_rec(this,''); };
var HxOverrides = function() { }
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
}
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
}
var StringBuf = function() {
	this.b = "";
};
var cosmicos = {}
cosmicos.Sound = function() {
};
$hxExpose(cosmicos.Sound, "cosmicos.Sound");
cosmicos.Sound.main = function() {
}
cosmicos.Sound.prototype = {
	textToWavUrl: function(text) {
		this.txt = new StringBuf();
		this.render(text);
		var enc = new haxe.crypto.BaseCode(haxe.io.Bytes.ofString("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"));
		var str = this.txt.b;
		var b = haxe.io.Bytes.alloc(str.length);
		var _g1 = 0;
		var _g = str.length;
		while(_g1 < _g) {
			var i = _g1++;
			b.set(i,str.charCodeAt(i));
		}
		return "data:audio/wav;base64," + enc.encodeBytes(b).toString();
	}
	,textToWav: function(text,content_mode) {
		this.txt = new StringBuf();
		if(content_mode) {
			this.txt.b += HxOverrides.substr("Content-Type: audio/x-wav",0,null);
			this.txt.b += "\n";
			this.txt.b += "\n";
		}
		this.render(text);
		var result = this.txt.b;
		return result;
	}
	,render: function(text) {
		var unit_len = 4000;
		var char_len = text.length;
		var sample_len = unit_len * char_len;
		var variation = 0.5;
		var qraise = Math.sqrt(Math.sqrt(2));
		var qminor = 2;
		var base = 2;
		this.show_header(sample_len);
		var v = 0;
		var n_prev = 0;
		var n2_prev = -1;
		var k_prev = 4;
		var _g = 0;
		while(_g < char_len) {
			var i = _g++;
			var k = HxOverrides.cca(text,i) - 48;
			var n = k;
			var n2 = -1;
			var chord = 0;
			if(k == 2) {
				base = base * qraise;
				n = base;
				chord = 1;
			}
			if(k == 3) {
				base = base / qraise;
				n = base;
				chord = 1;
			}
			if(k == 0) {
				n2 = base / qminor;
				n = base;
			}
			if(k == 1) {
				n2 = base * qminor;
				n = base;
			}
			var _g1 = 0;
			while(_g1 < unit_len) {
				var j = _g1++;
				var q = 0;
				var factor = j / 80.0;
				var tweak = 1 - Math.abs(j - unit_len / 2) / (unit_len / 2);
				if(factor > 1) factor = 1;
				if(k != 4 && k != 5) {
					q += factor * 100 * Math.sin(n * v);
					if(n2 >= 0) q += factor * 20 * Math.sin(n2 * v);
					if(chord != 0) {
					} else {
					}
				}
				if(k_prev != 4 && k_prev != 5) {
					if(i != 0) q += (1 - factor) * 100 * Math.sin(n_prev * v);
				}
				if(n2_prev >= 0) q += (1 - factor) * 20 * Math.sin(n2_prev * v);
				if(k == 4 || k == 5) {
					if(k == 4) {
						q += tweak * factor * 50 * Math.sin(base * v);
						q += tweak * factor * 25 * Math.sin(2 * base * v);
					} else {
						q += tweak * factor * 50 * Math.sin(base * v);
						q += tweak * factor * 25 * Math.sin(2 * base * v);
						q += tweak * factor * 12 * Math.sin(4 * base * v);
						q += tweak * factor * 12 * Math.sin(8 * base * v);
					}
				}
				this.show(128 + (q | 0),1);
				v += 0.1;
			}
			n_prev = n;
			k_prev = k;
			n2_prev = n2;
		}
	}
	,show_header: function(sample_len) {
		this.txt.b += HxOverrides.substr("RIFF",0,null);
		this.show(36 + sample_len,4);
		this.txt.b += HxOverrides.substr("WAVE",0,null);
		this.txt.b += HxOverrides.substr("fmt ",0,null);
		this.show(16,4);
		this.show(1,2);
		this.show(1,2);
		this.show(16000,4);
		this.show(16000,4);
		this.show(1,2);
		this.show(8,2);
		this.txt.b += HxOverrides.substr("data",0,null);
		this.show(sample_len,4);
	}
	,show: function(x,n) {
		var _g = 0;
		while(_g < n) {
			var i = _g++;
			var v = x % 256;
			this.txt.b += String.fromCharCode(v);
			x >>= 8;
		}
	}
}
var haxe = {}
haxe.crypto = {}
haxe.crypto.BaseCode = function(base) {
	var len = base.length;
	var nbits = 1;
	while(len > 1 << nbits) nbits++;
	if(nbits > 8 || len != 1 << nbits) throw "BaseCode : base length must be a power of two.";
	this.base = base;
	this.nbits = nbits;
};
haxe.crypto.BaseCode.prototype = {
	encodeBytes: function(b) {
		var nbits = this.nbits;
		var base = this.base;
		var size = b.length * 8 / nbits | 0;
		var out = haxe.io.Bytes.alloc(size + (b.length * 8 % nbits == 0?0:1));
		var buf = 0;
		var curbits = 0;
		var mask = (1 << nbits) - 1;
		var pin = 0;
		var pout = 0;
		while(pout < size) {
			while(curbits < nbits) {
				curbits += 8;
				buf <<= 8;
				buf |= b.get(pin++);
			}
			curbits -= nbits;
			out.set(pout++,base.b[buf >> curbits & mask]);
		}
		if(curbits > 0) out.set(pout++,base.b[buf << nbits - curbits & mask]);
		return out;
	}
}
haxe.io = {}
haxe.io.Bytes = function(length,b) {
	this.length = length;
	this.b = b;
};
haxe.io.Bytes.alloc = function(length) {
	var a = new Array();
	var _g = 0;
	while(_g < length) {
		var i = _g++;
		a.push(0);
	}
	return new haxe.io.Bytes(length,a);
}
haxe.io.Bytes.ofString = function(s) {
	var a = new Array();
	var _g1 = 0;
	var _g = s.length;
	while(_g1 < _g) {
		var i = _g1++;
		var c = s.charCodeAt(i);
		if(c <= 127) a.push(c); else if(c <= 2047) {
			a.push(192 | c >> 6);
			a.push(128 | c & 63);
		} else if(c <= 65535) {
			a.push(224 | c >> 12);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		} else {
			a.push(240 | c >> 18);
			a.push(128 | c >> 12 & 63);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		}
	}
	return new haxe.io.Bytes(a.length,a);
}
haxe.io.Bytes.prototype = {
	toString: function() {
		return this.readString(0,this.length);
	}
	,readString: function(pos,len) {
		if(pos < 0 || len < 0 || pos + len > this.length) throw haxe.io.Error.OutsideBounds;
		var s = "";
		var b = this.b;
		var fcc = String.fromCharCode;
		var i = pos;
		var max = pos + len;
		while(i < max) {
			var c = b[i++];
			if(c < 128) {
				if(c == 0) break;
				s += fcc(c);
			} else if(c < 224) s += fcc((c & 63) << 6 | b[i++] & 127); else if(c < 240) {
				var c2 = b[i++];
				s += fcc((c & 31) << 12 | (c2 & 127) << 6 | b[i++] & 127);
			} else {
				var c2 = b[i++];
				var c3 = b[i++];
				s += fcc((c & 15) << 18 | (c2 & 127) << 12 | c3 << 6 & 127 | b[i++] & 127);
			}
		}
		return s;
	}
	,set: function(pos,v) {
		this.b[pos] = v & 255;
	}
	,get: function(pos) {
		return this.b[pos];
	}
}
haxe.io.Error = { __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] }
haxe.io.Error.Blocked = ["Blocked",0];
haxe.io.Error.Blocked.toString = $estr;
haxe.io.Error.Blocked.__enum__ = haxe.io.Error;
haxe.io.Error.Overflow = ["Overflow",1];
haxe.io.Error.Overflow.toString = $estr;
haxe.io.Error.Overflow.__enum__ = haxe.io.Error;
haxe.io.Error.OutsideBounds = ["OutsideBounds",2];
haxe.io.Error.OutsideBounds.toString = $estr;
haxe.io.Error.OutsideBounds.__enum__ = haxe.io.Error;
haxe.io.Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe.io.Error; $x.toString = $estr; return $x; }
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
cosmicos.Sound.main();
function $hxExpose(src, path) {
	var o = typeof window != "undefined" ? window : exports;
	var parts = path.split(".");
	for(var ii = 0; ii < parts.length-1; ++ii) {
		var p = parts[ii];
		if(typeof o[p] == "undefined") o[p] = {};
		o = o[p];
	}
	o[parts[parts.length-1]] = src;
}
})();
