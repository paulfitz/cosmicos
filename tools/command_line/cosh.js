#!/usr/bin/env node

var cosmicos = require('../lib/cosmicos').cosmicos;
var cc = new cosmicos.Evaluate();
var cache = "";
cc.applyOldOrder();
cc.addStd();

function cosmicos_eval(input, context, filename, callback) {
    input = "" + input;
    var len = input.length;
    if (len>=3) {
        if (input[0]=='(' && input[len-1]==')' && input[len-2]=='\n') {
            // old-style node repl - strip extra parens
            input = input.substr(1,len-2);
        }
    }
    len = input.length;
    if (len>0) {
        if (input[len-1]=='\n') {
            // strip newline
            input = input.substr(0,len-1);
        }
    }
    len = input.length;
    if (len>=2) {
        if (input[0]=='(' && input[len-1]==')') {
            // we don't wrap top level statements any more
            input = input.substr(1,len-2);
        }
    }
    var input0 = input;
    if (cache!="") {
	input = cache + input;
    }
    var out = "";
    try {
	if (input==="help") {
	    out+= "Syntax:\n";
	    out+= "  Space-separated lists of integers with nesting e.g.: 1 2 3 (4 5) (6 7 (8 9))\n";
	    out+= "  Shorthand: symbols (listed below) can be used to stand for integers.\n";
	    out+= "  Shorthand: \"$x\" is equivalent to \"(x)\"\n";
	    out+= "  Shorthand: \"/\" nests to end of expression: (1 2 / 3 4) is equiv. to (1 2 (3 4))\n";
	    out+= "  Lists are evaluated by calling the first element with each of the others in turn.\n";
	    out+= "  If the first element of the list is a number, it is treated as a variable lookup.\n\n";
	    out+= "  Int Symbol  Meaning when called               Example\n";
	    var vocab = cc.getVocab();
	    var names = vocab.getNames();
	    for (var i=0; i<names.length; i++) {
                var lout = "";
		var name = names[i];
		var idx = "" + vocab.get(i);
		for (var j=idx.length; j<5; j++) {
		    lout += " ";
		}
		lout += idx;
		lout += " ";
		lout += name;
		for (var j=name.length; j<7; j++) {
		    lout += " ";
		}
                var meta = vocab.getMeta(name);
                var e = meta ? meta.description : null;
		if (e) {
		    lout += " " + e;
		    for (var j=e.length; j<33; j++) {
			lout += " ";
		    }
		    var ex = meta ? meta.example : null;
		    if (ex) {
			lout += " " + ex;
		    }
		}
		lout += "\n";
                if (e) {
                  out += lout;
                }
	    }
	    console.log(out);
	    out = true;
	} else if (input==="examples") {
          console.log(cc.examples().join("\n"));
          out = true;
	} else {
	    out = cc.evaluateLine(input);
	    if (out==null) {
		cache += input0 + "\n";
	    } else {
		var v = parseInt(out);
		if (""+v == out) out = v;
		cache = "";
	    }
	}
    } catch (e) {
	cache = "";
	out = "" + e;
    }
    if (cache=="") {
	callback(null, out);
    }
}

var args = process.argv.slice(2);

if (args.length == 0) {
    console.log("Welcome to a CosmicOS test console, \"help\" and \"examples\" available");
    repl = require('repl');
    repl.start({
	prompt: "cosmicos> ",
	input: process.stdin,
	output: process.stdout,
	eval: cosmicos_eval
    });
} else {
    if (args[0] == "-c") {
	var out = cc.evaluateLine(args[1]);
	var v = parseInt(out);
	if (""+v == out) out = v;
	console.log(out);
    }
}


