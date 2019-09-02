
var cos = require("./cosmic");
cos.language(2);
cos.seed(42);

var lst = [];
for (var i=0; i<16; i++) {
    cos.add(["=",i,cos.unary(i)]);
    lst.push(i);
}
var v = 1;
for (var i=0; i<5; i++) {
    cos.add(["=",v,cos.unary(v)]);
    v = v*2;
}

var lst2 = cos.permute(lst);
for (var i=0; i<16; i++) {
    var j = lst2[i];
    cos.add(["=",j,cos.unary(j)]);
}

var prev = {};
for (var i=0; i<8; i++) {
    var done = false;
    while (!done) {
	var r = cos.irand(8);
	var r2 = cos.irand(8);
	var idx = 100*r + r2;
	if (!prev[idx]) {
	    cos.add(["=",cos.unary(r+r2),[-1,"+",cos.unary(r),cos.unary(r2)]]);
	    cos.add(["=",r+r2,[-1,"+",r,r2]]);
	    prev[idx] = true;
	    done = true;
	}
    }
}

prev = {};
for (var i=0; i<8; i++) {
    var done = false;
    while (!done) {
	var r = cos.irand(4);
	var r2 = cos.irand(4);
	var idx = 100*r + r2;
	if (!prev[idx]) {
	    cos.add(["=",cos.unary(r*r2),[-1,"*",cos.unary(r),cos.unary(r2)]]);
	    cos.add(["=",r*r2,[-1,"*",r,r2]]);
	    prev[idx] = true;
	    done = true;
	}
    }
}
