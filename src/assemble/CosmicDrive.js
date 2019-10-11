var CosmicDrive = function(options) {

    var fs = require('fs');
    this.cosmicos = require("CosmicEval").cosmicos;
    this.spiders = require("SpiderScrawl").cosmicos;
    this.spider = new this.spiders.SpiderScrawl(null,0,0);

    this.all = JSON.parse(fs.readFileSync("assem.json", 'utf8'));
    this.config = new this.cosmicos.Config(fs.readFileSync("config.json", 'utf8'));
    var external_vocab_fname = this.config.getExternalVocabPath();
    if (external_vocab_fname != null) {
        this.config.setExternalVocab(fs.readFileSync(external_vocab_fname, 'utf8'));
    }
    this.state = new this.cosmicos.State(this.config);
    this.vocab = this.state.getVocab();
    this.primer = null;
    if (options['primer']) {
        this.primer = JSON.parse(fs.readFileSync("primer.json", 'utf8'));
        this.primer2 = JSON.parse(fs.readFileSync("primer2.json", 'utf8'));
    }
    this.txt = null;
    if (options['txt']) {
        this.txt = "";
    }
    this.codecs = {};
    this.options = options;

    // Add an extra Evaluate instance for checking messages recovered from 4-symbol codes.
    // This makes sure nothing functional is being lost in translation.
    var state2 = new this.cosmicos.State();
    state2.useIntVocab();
    var eval2 = new this.cosmicos.Evaluate(state2);
    eval2.applyOldOrder();
    eval2.addStdMin();
    var vocab = eval2.getVocab();
    var codec = new this.cosmicos.ChainCodec([
      new this.cosmicos.ParseCodec(vocab),
      new this.cosmicos.NormalizeCodec(vocab),
      new this.cosmicos.FourSymbolCodec(vocab),
    ]);
    this.rawEval = eval2;
    if (this.primer2) {
      this.rawEval.addPrimer(this.primer2);
    }
  this.stateInt = state2;
  this.vocabInt = vocab;
  this.rawRun = codec;
  
}

CosmicDrive.prototype.get_codec = function(key, fn) {
    if (!(key in this.codecs)) {
        this.codecs[key] = fn(this);
    }
    return this.codecs[key];
}

CosmicDrive.prototype.get_message = function() {
    return this.all;
}

CosmicDrive.prototype.get_coded_message = function() {
    return this.txt;
}

CosmicDrive.prototype.text_to_list = function(op) {
    var statement = new this.cosmicos.Statement(op);
    var prep = this.get_codec('prep',
                              function(self) {
                                  return new self.cosmicos.ChainCodec([
                                      new self.cosmicos.PreprocessCodec(self.state),
                                      new self.cosmicos.ParseCodec(self.vocab),
                                      new self.cosmicos.NormalizeCodec(self.vocab),
                                      new self.cosmicos.UnflattenCodec()
                                  ]);
                              });
    prep.encode(statement);
    return statement.content;
}

CosmicDrive.prototype.text_to_list_int = function(op) {
    var statement = new this.cosmicos.Statement(op);
    var prep = this.get_codec('prep_int',
                              function(self) {
                                  return new self.cosmicos.ChainCodec([
                                      new self.cosmicos.PreprocessCodec(self.stateInt),
                                      new self.cosmicos.ParseCodec(self.vocabInt),
                                      new self.cosmicos.NormalizeCodec(self.vocabInt),
                                      new self.cosmicos.UnflattenCodec()
                                  ]);
                              });
    prep.encode(statement);
    return statement.content;
}

CosmicDrive.prototype.complete_stanza = function(stanza, can_run) {
    var part = stanza;
    var op = part.lines.join("\n");

    var preprocess = this.get_codec('preprocess',
                                    function(self) { 
                                        return new self.cosmicos.PreprocessCodec(self.state);
                                    });
    var parse = this.get_codec('parse',
                               function(self) { 
                                   return new self.cosmicos.ParseCodec(self.vocab);
                               });
    var unparse = this.get_codec('unparse',
                                 function(self) { 
                                     return new self.cosmicos.ParseCodec(self.vocab, false);
                                 });
    var symbol = this.get_codec('symbol',
                                 function(self) { 
                                     return new self.cosmicos.FourSymbolCodec(self.vocab);
                                 });
    var norm = this.get_codec('norm',
                                 function(self) { 
                                     return new self.cosmicos.NormalizeCodec(self.vocab);
                                 });
    var run = this.get_codec('run',
                             function(self) { 
                                 var run = new self.cosmicos.ChainCodec([
                                     new self.cosmicos.NormalizeCodec(self.vocab),
                                     new self.cosmicos.UnflattenCodec(),
                                     new self.cosmicos.TranslateCodec(self.state),
                                     new self.cosmicos.EvaluateCodec(self.state, false)
                                 ]);
                                 if (self.options['primer']) {
                                     run.last().addPrimer(self.primer);
                                 }
                                 return run;
                             });

    console.log("====================================================");

    var statement = this.complete_stanza_core(null, part, can_run);
    var v = statement.content[0];
    console.log("  ", v);
  
    if (op.indexOf("demo ")==0) {
        var backtrack = statement.copy();
        run.decode(backtrack);
        unparse.decode(backtrack);
        preprocess.decode(backtrack);
	var r = backtrack.content[0];
        op = "equal " + r + " " + op.substr(5,op.length);
        part["lines_original"] = part["lines"];
        part["lines"] = [op];
        this.complete_stanza_core(op,part,false);
	v = 1;
    }

    return v;
}

CosmicDrive.prototype.complete_stanza_core = function(op, stanza, can_run) {
    var part = stanza;
    var op = op || part.lines.join("\n");
    var statement = new this.cosmicos.Statement(op);

    var preprocess = this.get_codec('preprocess', null);
    var parse = this.get_codec('parse', null);
    var unparse = this.get_codec('unparse', null);
    var symbol = this.get_codec('symbol', null);
    var norm = this.get_codec('norm', null);
    var run = this.get_codec('run', null);

    preprocess.encode(statement);
    var preprocessed = statement.content[0];
    parse.encode(statement);
    var parsed = statement.copy();
    var encoded = statement.copy();
    norm.encode(encoded);
    symbol.encode(encoded);
    var code = encoded.content[0];
    if (part!=null) {
        part["preprocessed"] = preprocessed;
	part["code"] = code;
	part["parse"] = parsed.content;
        part["spider"] = this.spider.addString(code);
        part["dt"] = this.cosmicos.Parse.looksLikeMutation(parsed.content);
    }
    var cline = 999;
    console.log(cline + ": " + op + "  -->  " + code);
    if (this.txt != null) {
        this.txt += code;
        this.txt += "\n";
    }
    if (!can_run) return new this.cosmicos.Statement(1);
    // to make sure we don't have a bug in the message, recover it from low-level
    // coding before evaluating.
    var parsed2 = parsed.copy();
    this.cosmicos.Parse.encodeSymbols(parsed2.content, this.state.getVocab(), true);
    var recoveredStatement = new this.cosmicos.Statement(code);
    this.rawRun.decode(recoveredStatement);
    var zing = recoveredStatement.copy();
    parse.encode(zing);
    this.cosmicos.Parse.encodeSymbols(zing.content, this.state.getVocab(), true);
    if (!this.cosmicos.Parse.softCompare(zing.content, parsed2.content)) {
      throw new Error('code fails round-trip test');
    }
    try {
      run.encode(statement);
      return statement;
      // var result = this.rawEval.evaluateLine(recoveredStatement.content[0]);
      // return new this.cosmicos.Statement(result);
    } catch(e) {
      throw e;
    }
}

CosmicDrive.prototype.add_line_numbers = function() {
    var all = this.all;
    var ct = 0;
    for (var i=0; i<all.length; i++) {
        all[i]["stanza"] = ct;
        ct++;
    }
}

module.exports = CosmicDrive;
