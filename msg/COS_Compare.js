
var cos = require("./cosmic");

cos.language(2);
cos.seed(42);

cos.add(["intro","="]);

var examples = [1, 2, 3, 4, 5, 6, 7, 8, 1, 6, 2];
var examples2 = [];
for (var i=0; i<examples.length; i++) {
    var r = examples[i];
    cos.add("= " + cos.unary(r) + " " + cos.unary(r));
}

cos.doc("Now introduce symbols for 'greater than' and 'less than,' and contrast with equality.");
cos.doc("Hopefully the listener will start to understand what part of the sentences are numbers, " +
        "what part is a function of the relationship between the numbers, " +
        "and what parts are just meaningless (for now) scaffolding around all that.");
cos.doc("There's an ambiguity between the 'greater than' and 'less than' symbols, depending " +
        "on how you interpret the sentences, but it doesn't matter yet.");

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

cos.doc("Add some random examples.");

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

cos.doc("Even more random examples.  We shouldn't be shy about piling on examples " +
        "at this early stage of the message.  Even just the repetition of the sentence " +
        "structure with many small variations could help guide the listener at a more " +
        "fundamental level than what we're ostensibly trying to communicate here.");

prev = "";
for (var i=0; i<=20; i++) {
    var done = false;
    while (!done) {
	var r = cos.irand(5);
	var r2 = cos.irand(5);
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

