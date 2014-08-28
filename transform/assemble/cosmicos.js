var fs = require('fs');

var msg = null;
var stanza = -1;
var last_stanza = -1;
var output = "";
var vocab = "";

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

function showText(root,src) {
    process.stdout.write("<!DOCTYPE html>\
<html lang='en'>\
  <head>\
    <meta charset='utf-8'>\
    <title>CosmicOS</title>\
<style type='text/css'>\
 .koan {\
   font-size: 32px; \
 }\
 img {\
   height: 32px; \
   vertical-align:middle; \
 }\
</style>\
  </head>\
  <body>\
");
    var ev = require(root + "/transform/CosmicEval.js").cosmicos;
    var render = new ev.ManuscriptStyle();
    var letters_src = {};
    if (vocab) {
	letters_src = require(vocab);
    }
    var letters = {};
    if (letters_src["vocab"]) {
	var lst = letters_src["vocab"];
	for (var i=0; i<lst.length; i++) {
	    var e = lst[i];
	    letters[e.title] = e;
	}
    }

    for (var s=stanza; s<=last_stanza; s++) {
	var m = msg[s];
	var parse = m["parse"];
	if (!parse) {
	    if (m["role"] == "comment") {
		process.stdout.write("<pre>\n");
		var lines = m["lines"];
		for (var i=0; i<lines.length; i++) {
		    process.stdout.write(lines[i]);
		    process.stdout.write("\n");
		}
		process.stdout.write("</pre>\n");
	    }
	    continue;
	}
	process.stdout.write("<div class='koan' data-id='" + s + "'>\n  ");
	var txt = render.render(parse);
	var nb = false;
	for (var i=0; i<txt.length; i++) {
	    var e = txt[i];
	    var letter = letters[e];
	    if (letter) {
		if (letter.media) {
		    process.stdout.write("<img src='" + letter.media + "'/>");
		} else {
		    var vs = letter.alias.split(":");
		    for (var j=0; j<vs.length; j++) {
			var v = vs[j];
			var letterv = letters[v];
			if (letterv && letterv.media) {
			    process.stdout.write("<img src='" + letterv.media + "'/>");
			}
		    }
		}
	    } else {
		var t = "" + e;
		if (t.length>1) {
		    if (nb) {
			process.stdout.write(":");
		    }
		    nb = true;
		} else {
		    nb = false;
		}
		if (t == " ") {
		    t = "&#x2000;";
		}
		process.stdout.write(t);
	    }
	}
	process.stdout.write("&nbsp;~\n</div>\n");
    }
    process.stdout.write("\
  </body>\
</html>\
");
}

module.exports = function(root,src) {
    msg = JSON.parse(fs.readFileSync(root + "/index.json", 'utf8'));
    var argv = process.argv;
    for (var i=3; i<argv.length; i++) {
	if (argv[i-1]=="-p") {
	    stanza = parseInt(argv[i]);
	}
	if (argv[i-1]=="-P") {
	    last_stanza = parseInt(argv[i]);
	}
	if (argv[i-1]=="-o") {
	    output = argv[i];
	}
	if (argv[i-1]=="-v") {
	    vocab = argv[i];
	}
    }
    if (last_stanza == -1) {
	last_stanza = stanza;
    }
    var cmd = argv[2];
    if (cmd == 'show') {
	needStanza();
	for (var s=stanza; s<=last_stanza; s++) {
	    console.log(msg[s]);
	}
	return 0;
    }
    if (cmd == 'text') {
	needStanza();
	showText(root,src);
	return 0;
    }
    if (cmd == 'hear') {
	var cos = require(root + "/transform/CosmicAudio.js").cosmicos;
	var snd = new cos.Sound();
	needStanza();
	needOutput();
	if (last_stanza!=stanza) {
	    throw("audio cannot do multiple parts yet");
	}
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
    console.log("  cosmsg text -p NNNN -v vocab.json # experimental text rendering of message part NNNN");
}



