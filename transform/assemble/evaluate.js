var fs = require('fs');
var assert = require('assert');
var cos = require("CosmicEval").cosmicos;

var all = JSON.parse(fs.readFileSync("assem.json", 'utf8'));
// var all = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));

var ev = new cos.Evaluate();
ev.applyOldOrder();

var txt = "";

function run(op) {
    console.log("====================================================");
    var code = ev.codifyLine(op);
    console.log(cline + ": " + op + "  -->  " + code);
    txt += code;
    txt += "\n";
    var v = ev.evaluateLine(op);
    console.log(cos.Parse.textify(cos.Parse.deconsify(v),ev.vocab));
    console.log(v);
    return v;
}

try {
    var cline = 0;
    for (var i=0; i<all.length && i<1500; i++) {
	var part = all[i];
	if (part.role != "code") continue;
	var op = part.lines.join("\n");
	// now using one layer less of nesting
	op = op.replace(/^\(/,"");
	op = op.replace(/\);/,"");
	var v = run(op);
	assert(v==1);
	cline++;
    }
} catch (e) {
    console.log("Problem: " + e);
    // continue for now, to compare with old version
}

//console.log(txt);
//txt = txt.match(/.{1,80}/g).join("\n");
fs.writeFileSync('q.txt',txt);

module.exports = run;
