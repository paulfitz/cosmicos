var fs = require('fs');
var assert = require('assert');
var cos = require("CosmicEval").cosmicos;

var all = JSON.parse(fs.readFileSync("assem.json", 'utf8'));
// var all = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));


var ev = new cos.Evaluate();
ev.applyOldOrder();

try {
    var primer = JSON.parse(fs.readFileSync("primer.json", 'utf8'));
    ev.addPrimer(primer);
} catch (e) {
    console.log("No primer available");
    throw(e);
}


var txt = "";

function run(op) {
    console.log("====================================================");
    var code = ev.codifyLine(op);
    console.log(cline + ": " + op + "  -->  " + code);
    txt += code;
    txt += "\n";
    var v = ev.evaluateLine(op);
    //console.log(JSON.stringify(cos.Parse.deconsify(v),ev.vocab));
    //console.log(v);
    return v;
}

try {
    var cline = 0;
    for (var i=0; i<all.length && i<3000; i++) {
	var part = all[i];
	if (part.role != "code") continue;
	cline++;
	var op = part.lines.join("\n");
	// now using one layer less of nesting

	if (true) {
	    if (op.indexOf("distill-circuit")>=0) {
		console.log("Skipping distill-circuit");
		continue;
	    }
	    if (op.indexOf("_harness")>=0) {
		console.log("Skipping _harness");
		continue;
	    }
	    if (op.indexOf("even-natural")>=0) {
		console.log("Skipping even-natural");
		continue;
	    }
	}

	op = op.replace(/^\(/,"");
	op = op.replace(/\);/,"");
	var v = run(op);

	if (op.indexOf("demo ")==0) {
	    var r = cos.Parse.recover(cos.Parse.deconsify(v));
	    console.log("Evaluated to: " + r);
	    op = "equal " + r + " " + op.substr(5,op.length);
	    // v = run(op); // will need a separate pass for this
	    part["lines_original"] = part["lines"];
	    part["lines"] = [ "(" + op + ");" ];
	    console.log(">>> " + op);
	    v = 1;
	}

	assert(v==1);
    }
} catch (e) {
    console.log("Problem: " + e);
    // continue for now, to compare with old version
}

//console.log(txt);
//txt = txt.match(/.{1,80}/g).join("\n");
fs.writeFileSync('q.txt',txt);
fs.writeFileSync('assem2.json',JSON.stringify(all, null, 2));

module.exports = run;
