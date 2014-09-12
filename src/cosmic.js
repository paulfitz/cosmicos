
function CosWrite() {
    this.rw = 1;
}

CosWrite.prototype.language = function(n) {
}

CosWrite.prototype.getPseudo = function() {
    var T16 = 0x10000;
    var T32 = T16*T16;
    var cons = 0x0808;
    var tant = 0x8405;
    var X = this.rw*cons % T16 * T16 + this.rw*tant + 1;
    this.rw = X % T32;
    return this.rw/T32;
}

CosWrite.prototype.seed = function(v) {
    this.rw = v;
}

CosWrite.prototype.irand = function(top) {
    var v = Math.floor(this.getPseudo()*top);
    return v % top;
}

CosWrite.prototype.permute = function(lst) {
    lst = lst.slice();
    var out = [];
    while (lst.length>0) {
	out = out.concat(lst.splice(this.irand(lst.length),1));
    }
     return out;
}

CosWrite.prototype.bag = function(first,last) {
    var lst = [];
    for (var i=first; i<=last; i++) {
	lst.push(i);
    }
    return this.permute(lst);
}

CosWrite.prototype.prand = function(top,crop) {
    var lst = this.bag(0,top-1);
    return lst.slice(0,crop);
}

CosWrite.prototype.add = function(s) {
    if (typeof s == 'object') {
	s = this.stringify(s,false);
    }
    console.log(s + ";");
}

CosWrite.prototype.stringify = function(x,nested) {
    var txt = "";
    var mode = 0;
    var offset = 0;
    var nws = false;
    if (x.length>1) {
	if (typeof x[0] == 'number') {
	    mode = x[0];
	    if (mode>=0) {
		mode = 0;
	    } else {
		offset = 1;
	    }
	}
    }
    if (nested) {
	if (nws) {
	    txt += " ";
	    nws = false;
	}
	if (mode==0) {
	    txt += "(";
	} else if (mode==-1) {
	    txt += "|";
	    nws = true;
	} else if (mode==-2) {
	    txt += "$";
	}
    }
    for (var i=offset; i<x.length; i++) {
	if (nws) {
	    txt += " ";
	    nws = false;
	}
	var xi = x[i];
	if (typeof xi == 'object') {
	    txt += this.stringify(xi,true);
	} else {
	    txt += xi;
	}
	nws = true;
    }
    if (nested && mode==0) {
	txt += ")";
    }
    return txt;
}

CosWrite.prototype.section = function(txt,tag) {
    console.log("# " + tag + " " + txt);
}

CosWrite.prototype.comment = function(txt) {
    var len = 74;
    while (txt!="") {
	var tlen = len;
	var t = txt;
	if (txt.length>tlen) {
	    var at = tlen-1;
	    while(at>=0 && txt[at]!=' ') {
		at--;
	    }
	    while(at>=0 && txt[at]==' ') {
		at--;
	    }
	    tlen = at+1;
	    if (tlen<1) tlen = 1;
	    t = txt.substr(0,tlen);
	    txt = txt.substr(tlen,txt.length);
	    console.log("# " + t.trim());
	} else {
	    console.log("# " + txt.trim());
	    txt = "";
	}
    }
}

CosWrite.prototype.unary = function(ct) {
    var txt = "(unary";
    for (var i=0; i<ct; i++) {
	txt += " 1";
    }
    txt += " 0)";
    return txt;
};

CosWrite.prototype.$ = function(x) {
    return [ -2, x ];
}

CosWrite.prototype.tail = function(lst) {
    return [ -1 ].concat(lst);
}

module.exports = new CosWrite();
