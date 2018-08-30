var fs = require('fs');
var cosmicos = require("CosmicEval").cosmicos;

var all = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));

var config = new cosmicos.Config(fs.readFileSync("config.json", 'utf8'));
var state = new cosmicos.State(state);
var vocab = state.getVocab();

var prep = new cosmicos.ChainCodec([
    new cosmicos.PreprocessCodec(state),
    new cosmicos.ParseCodec(vocab),
    new cosmicos.NormalizeCodec(vocab)
]);
var run = new cosmicos.EvaluateCodec(state);

for (var i=0; i<all.length; i++) {
    var part = all[i];
    if (part.role != "code") continue;
    var op = part.lines.join("\n");
    prep.encode(new cosmicos.Statement(op));
}

var vocab = {};
var names = state.getVocab().getNames();

console.log(names);
for (var i=0; i<names.length; i++) {
    var name = names[i];
    var code = state.getVocab().get(name);
    vocab[name] = code;
}

fs.writeFileSync("vocab.json", JSON.stringify(vocab, null, 2));
