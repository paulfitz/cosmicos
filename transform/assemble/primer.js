var fs = require('fs');
var assert = require('assert');
var cos = require("CosmicEval").cosmicos;

var all = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
var primer = [];

var ev = new cos.Evaluate();
ev.applyOldOrder();

try {
    var cline = 0;
    for (var i=0; i<all.length; i++) {
	var part = all[i];
	if (part.role != "code") continue;
	var op = part.lines.join("\n");
	var v = ev.numberizeLine(op);
	cos.Parse.removeSlashMarker(v);
	console.log(JSON.stringify(v));
	primer.push(v);
	cline++;
    }
} catch (e) {
    console.log("Problem: " + e);
    // continue for now, to compare with old version
    throw e;
}


var fname = "primer.json";
fs.writeFile(fname, JSON.stringify(primer, null, 2), function(err) {
    if(err) {
	console.log(err);
    } else {
	console.log("JSON saved to " + fname);
    }
}); 