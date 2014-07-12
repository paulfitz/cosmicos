#!/usr/bin/env node

console.log("[See http://cosmicos.github.io/evaluate.html for help]");

var cosmicos = require('../lib/cosmicos').cosmicos;
var cc = new cosmicos.Evaluate();
cc.addStd();

function cosmicos_eval(input, context, filename, callback) {
    input = "" + input;
    input = input.substr(1,input.length-3);
    var out = "";
    try {
	if (input=="help") {
	    out+= "Syntax:\n";
	    out+= "  Space-separated lists of integers with nesting e.g.: 1 2 3 (4 5) (6 7 (8 9))\n";
	    out+= "  Shorthand: symbols (listed below) can be used to stand for integers.\n";
	    out+= "  Shorthand: \"$x\" is equivalent to \"(x)\"\n";
	    out+= "  Shorthand: \"/\" nests to end of expression: (1 2 / 3 4) is equiv. to (1 2 (3 4))\n";
	    out+= "  Lists are evaluated by calling the first element with each of the others in turn.\n";
	    out+= "  If the first element of the list is a number, it is treated as a variable lookup.\n";
	    out+= "Index Symbol  Meaning                           Example\n";
	    var vocab = cc.getVocab();
	    var names = vocab.getNames();
	    for (var i=0; i<names.length; i++) {
		var name = names[i];
		var idx = "" + vocab.get(i);
		for (var j=idx.length; j<5; j++) {
		    out += " ";
		}
		out += idx;
		out += " ";
		out += name;
		for (var j=name.length; j<7; j++) {
		    out += " ";
		}
		var e = "(missing)"; // no explanation
		if (e) {
		    out += " " + e;
		    for (var j=e.length; j<33; j++) {
			out += " ";
		    }
		    var ex = "(see http://cosmicos.github.io/evaluate.html)" // no example
		    if (ex) {
			out += " " + ex;
		    }
		}
		out += "\n";
	    }
	    console.log(out);
	    out = true;
	} else {
	    out = cc.evaluateLine(input);
	    var v = parseInt(out);
	    if (""+v == out) out = v;
	}
    } catch (e) {
	out = "" + e;
    }
    callback(null, out);
}

repl = require('repl');
repl.start({
    prompt: "cosmicos> ",
    input: process.stdin,
    output: process.stdout,
    eval: cosmicos_eval
});

