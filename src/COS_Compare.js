
var cos = require("./cosmic");

cos.language(2);
cos.seed(42);

cos.section("introduce equality for unary numbers","MATH");
cos.comment("The intro operator does nothing essential, and could be omitted - it just tags the first use of a new operator. The = operator is introduced alongside a duplication of unary numbers.  The meaning will not quite by nailed down until we see other relational operators.");
cos.add(["intro","="]);

var examples = [1, 2, 3, 4, 5, 6, 7, 8, 1, 6, 2];
var examples2 = [];
for (var i=0; i<examples.length; i++) {
    var r = examples[i];
    cos.add("= " + cos.unary(r) + " " + cos.unary(r));
}

cos.section("now introduce other relational operators","MATH");
cos.comment("After this lesson, it should be clear what contexts < > and = are appropriate in.");

cos.add(["intro",">"]);
cos.add(["intro","<"]);

var prev = "";
for (var i=1; i<=4; i++) {
    for (var j=1; j<=4; j++) {
	var r = j;
	var r2 = i;
	var idx = r*100+r2;
	var cmp = "=";
	if (r<r2) {
	    cmp = ">";
	} else if (r>r2) {
	    cmp = "<";
	}
	cos.add([cmp,cos.unary(r2),cos.unary(r)]);
	prev[idx] = true;
    }
}

cos.comment("Some random examples");

prev = {};
for (var i=0; i<=10; i++) {
    var done = false;
    while (!done) {
	var r = cos.irand(10)+1;
	var r2 = cos.irand(r);
	var idx = r*100+r2;
	if (!prev[idx]) {
	    cos.add([">",cos.unary(r),cos.unary(r2)]);
	    prev[idx] = true;
	    done = true;
	}
    }
}

prev = {};
for (var i=0; i<=10; i++) {
    var done = false;
    while (!done) {
	var r = cos.irand(10)+1;
	var r2 = cos.irand(r);
	var idx = r*100+r2;
	if (!prev[idx]) {
	    cos.add(["<",cos.unary(r2),cos.unary(r)]);
	    prev[idx] = true;
	    done = true;
	}
    }
}

cos.comment("A few more random examples");

prev = "";
for (var i=0; i<=10; i++) {
    var done = false;
    while (!done) {
	var r = cos.irand(6);
	var r2 = cos.irand(6);
	var idx = r*100+r2;
	if (!prev[idx]) {
	    var cmp = "=";
	    if (r>r2) {
		cmp = ">";
	    } else if (r<r2) {
		cmp = "<";
	    }
	    cos.add([cmp,cos.unary(r),cos.unary(r2)]);;
	    prev[idx] = true;
	    done = true;
	}
    }
}

