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

function run(op,part,skippy) {
    console.log("====================================================");
    var code = ev.codifyLine(op);
    var nest = ev.nestedLine(op);
    if (part!=null) {
	part["code"] = code;
	part["parse"] = nest;
    }
    console.log(cline + ": " + op + "  -->  " + code);
    process.stderr.write(cline + ": " + op + " --> " + code + "\n"); // TODO: just for debug
    txt += code;
    txt += "\n";
    if (skippy) return 1;
    process.stderr.write("evaluating ... ");
    var v = ev.evaluateLine(op);
    process.stderr.write("OK -> v = " + v + " (should be 1)\n");
    console.log(JSON.stringify(cos.Parse.deconsify(v),ev.vocab));
    console.log(v);
    return v;
}

var err_part = null;
var err_i = -1;
try {
    //throw "skip it all";
    var cline = 0;
    for (var i=0; i<all.length && i<5000; i++) {
	var part = all[i];
	err_part = part;
	err_i = i;
	if (part.role != "code") continue;
	cline++;
	var op = part.lines.join("\n");
	// now using one layer less of nesting

	var skippy = false;
	// skip the most time consuming parts of message for now
	if (true) {
	    if (op.indexOf("distill-circuit")>=0) {
		process.stderr.write("Skipping distill-circuit\n");
		skippy = true;
	    }
	    if (op.indexOf("_harness")>=0) {
		process.stderr.write("Skipping _harness\n");
		skippy = true;
	    }
	    if (op.indexOf("even-natural")>=0) {
		process.stderr.write("Skipping even-natural\n");
		skippy = true;
	    }
	} else {
	    process.stderr.write("At " + i + "\n");
	}

	/*
	if (op[0] == '(') {
	    op = op.replace(/^\(/,"");
	    op = op.replace(/\);/,"");
	    if (part.lines.length>0) {
		part.lines[0] = part.lines[0].replace(/^\(/,"");
		part.lines[part.lines.length-1] = part.lines[part.lines.length-1].replace(/\);/,";");
	    }
	}
	*/

	var v = run(op,part,skippy);

	if (op.indexOf("demo ")==0) {
	    var r = cos.Parse.recover(cos.Parse.deconsify(v));
	    console.log("Evaluated to: " + r);
	    op = "equal " + r + " " + op.substr(5,op.length);
	    // v = run(op); // will need a separate pass for this
	    part["lines_original"] = part["lines"];
	    part["lines"] = [ "(" + op + ");" ];
	    part["code"] = ev.codifyLine(op);
	    part["parse"] = ev.nestedLine(op);
	    console.log(">>> " + op);
	    v = 1;
	}

	if (v!=1) {
	    throw v;
	}
	assert(v==1);
    }
} catch (e) {
    process.stderr.write("* evaluate.js failed on " + err_i + ": " + JSON.stringify(err_part) + "\n");
    // continue for now, to compare with old version
    //throw(e);
}


var ct = 0;
for (var i=0; i<all.length; i++) {
    var splitter = /^# ([A-Z][A-Z]+) (.*)/;
    var part = all[i];
    if (part.role != "comment") continue;
    if (part.lines.length==0) continue;
    var match = splitter.exec(part.lines[0]);
    if (match == null) continue;
    part["section_description"] = match[2];
    part["section_category"] = match[1];
    part["section_index"] = ct;
    ct++;
}

for (var i=0; i<all.length; i++) {
    var splitter = /^>>> ([_A-Z0-9]+)\.gate/;
    var part = all[i];
    if (part.role != "gate") continue;
    if (part.lines.length==0) continue;
    var match = splitter.exec(part.lines[0]);
    if (match == null) continue;
    part["thumbnail"] = match[1] + ".gif";
    part["page"] = match[1] + ".html";
}

ct = 0;
for (var i=0; i<all.length; i++) {
    all[i]["stanza"] = ct;
    ct++;
}

//console.log(txt);
//txt = txt.match(/.{1,80}/g).join("\n");
fs.writeFileSync('q.txt',txt);
fs.writeFileSync('assem2.json',JSON.stringify(all, null, 2));

module.exports = run;
