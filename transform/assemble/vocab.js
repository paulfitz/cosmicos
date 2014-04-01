var fs = require('fs');
var assert = require('assert');
var cos = require("CosmicEval").cosmicos;

var all = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
var primer = [];

var ev = new cos.Evaluate();
ev.applyOldOrder();

for (var i=0; i<all.length; i++) {
    var part = all[i];
    if (part.role != "code") continue;
    var op = part.lines.join("\n");
    var v = ev.numberizeLine(op);
}

var vocab = {};
var names = ev.getVocab().getNames();

console.log(names);
for (var i=0; i<names.length; i++) {
    var name = names[i];
    var code = ev.getVocab().get(name);
    vocab[name] = code;
}

var fname = "vocab.json";
fs.writeFile(fname, JSON.stringify(vocab, null, 2), function(err) {
    if(err) {
	console.log(err);
    } else {
	console.log("JSON saved to " + fname);
    }
}); 