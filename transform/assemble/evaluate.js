var fs = require('fs');
var cos = require("CosmicEval").cosmicos;

var all = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));

var ev = new cos.Evaluate();
ev.applyOldOrder();

for (var i=0; i<all.length && i<300; i++) {
    var part = all[i];
    if (part.role != "code") continue;
    var op = part.lines.join("\n");
    // now using one layer less of nesting
    op = op.replace(/^\(/,"");
    op = op.replace(/\);/,"");
    console.log(op);
    console.log(op + "  -->  " + ev.codifyLine(op));
    console.log(cos.Parse.stringToList(op,ev.vocab));
    console.log(ev.numberizeLine(op));
    console.log(ev.codifyLine(op));
    console.log(ev.evaluateLine(op));
}


