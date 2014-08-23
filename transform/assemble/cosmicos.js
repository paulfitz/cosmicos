var fs = require('fs');

var msg = null;
var stanza = -1;
var output = "";

function needStanza() {
    if (stanza==-1) {
	throw "Please specify a message part with -p NNNN";
    }
}

function needOutput() {
    if (output=="") {
	throw "Please specify where output should go with -o <filename>";
    }
}

function showText(root,parse) {
    console.log(parse);
    var ev = require(root + "/transform/CosmicEval.js").cosmicos;
    var render = new ev.ManuscriptStyle();
    render.render(parse);
}

module.exports = function(root) {
    msg = JSON.parse(fs.readFileSync(root + "/index.json", 'utf8'));
    var argv = process.argv;
    for (var i=3; i<argv.length; i++) {
	if (argv[i-1]=="-p") {
	    stanza = parseInt(argv[i]);
	}
	if (argv[i-1]=="-o") {
	    output = argv[i];
	}
    }
    var cmd = argv[2];
    if (cmd == 'show') {
	needStanza();
	console.log(msg[stanza]);
	return 0;
    }
    if (cmd == 'text') {
	needStanza();
	var parse = msg[stanza].parse;
	if (parse) {
	    showText(root,parse);
	}
	return 0;
    }
    if (cmd == 'hear') {
	var cos = require(root + "/transform/CosmicAudio.js").cosmicos;
	var snd = new cos.Sound();
	needStanza();
	needOutput();
	var code = msg[stanza].code;
	if (!code) throw "code not found for part " + stanza;
	var txt = snd.textToWav(code,false);
	fs.writeFileSync(output,txt,"binary");
	console.log("Wrote to " + output);
	return 0;
    }
    console.log("Welcome to the CosmicOS message inspector command. Usage:");
    console.log("  cosmsg show -p NNNN               # show info about message part NNNN");
    console.log("  cosmsg hear -p NNNN -o audio.wav  # convert message part to audio");
}



