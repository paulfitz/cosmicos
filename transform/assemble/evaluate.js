var fs = require('fs');
var cosmicos = require("CosmicEval").cosmicos;
var spiders = require("SpiderScrawl").cosmicos;
var spider = new spiders.SpiderScrawl(null,0,0);

var all = JSON.parse(fs.readFileSync("assem.json", 'utf8'));

var config = new cosmicos.Config(fs.readFileSync("config.json", 'utf8'));
var state = new cosmicos.State(config);
var vocab = state.getVocab();

var primer = JSON.parse(fs.readFileSync("primer.json", 'utf8'));

var preprocess = new cosmicos.PreprocessCodec(state);
var parse = new cosmicos.ParseCodec(vocab);
var unparse = new cosmicos.ParseCodec(vocab, false);
var symbol = new cosmicos.FourSymbolCodec(vocab);
var run = new cosmicos.ChainCodec([
    new cosmicos.NormalizeCodec(vocab),
    new cosmicos.UnflattenCodec(),
    new cosmicos.TranslateCodec(state),
    new cosmicos.EvaluateCodec(state, false)
]);
run.last().addPrimer(primer);

var txt = "";

function run_core(op,part,skippy) {
    console.log("Working on {" + op + "}");
    var statement = new cosmicos.Statement(op);
    preprocess.encode(statement);
    var preprocessed = statement.content[0];
    parse.encode(statement);
    var parsed = statement.copy();
    var encoded = statement.copy();
    symbol.encode(encoded);
    var code = encoded.content[0];
    if (part!=null) {
        part["preprocessed"] = preprocessed;
	part["code"] = code;
	part["parse"] = parsed.content;
        part["spider"] = spider.addString(code);
    }
    console.log(cline + ": " + op + "  -->  " + code);
    txt += code;
    txt += "\n";
    if (skippy) return new cosmicos.Statement(1);
    run.encode(statement);
    return statement;
}

function run_line(op,part,skippy) {
    console.log("====================================================");

    var statement = run_core(op,part,skippy,true);
    var v = statement.content[0];

    if (op.indexOf("demo ")==0) {
        var backtrack = statement.copy();
        run.decode(backtrack);
        unparse.decode(backtrack);
        preprocess.decode(backtrack);
	var r = backtrack.content[0];
	op = "equal " + r + " " + op.substr(5,op.length);
	part["lines_original"] = part["lines"];
        part["lines"] = [op];
        run_core(op,part,true);  // have to skip because of a demo of operation with side-effects
	v = 1;
    }

    return v;
}

var err_part = null;
var err_i = -1;
var line_limit = config.lines();
try {
    var cline = 0;
    for (var i=0; i<all.length && (i<line_limit || line_limit==0); i++) {
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

        var v = run_line(op,part,skippy);
	if (v!=1) {
	    throw v;
	}
    }
} catch (e) {
    process.stderr.write("* evaluate.js failed on " + err_i + ": " + JSON.stringify(err_part) + "\n");
    throw(e);
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

fs.writeFileSync('q.txt',txt);
fs.writeFileSync('assem2.json',JSON.stringify(all, null, 2));

module.exports = run;
