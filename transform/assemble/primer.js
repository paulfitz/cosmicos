var fs = require('fs');
var cosmicos = require("CosmicEval").cosmicos;

var all = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
var primer = [];

var config = new cosmicos.Config(fs.readFileSync("config.json", 'utf8'));
var state = new cosmicos.State(state);
var vocab = state.getVocab();

var prep = new cosmicos.ChainCodec([
    new cosmicos.PreprocessCodec(state),
    new cosmicos.ParseCodec(vocab),
    new cosmicos.NormalizeCodec(vocab),
    new cosmicos.UnflattenCodec()
]);

var cline = 0;
for (var i=0; i<all.length; i++) {
    var part = all[i];
    if (part.role != "code") continue;
    var op = part.lines.join("\n");
    var statement = new cosmicos.Statement(op);
    prep.encode(statement);
    var v = statement.content;
    console.log(JSON.stringify(v));
    primer.push(v);
    cline++;
}

fs.writeFileSync("primer.json", JSON.stringify(primer, null, 2));
