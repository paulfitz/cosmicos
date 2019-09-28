var fs = require('fs');
var path = require('path');

var msg = null;
var stanza = -1;
var last_stanza = -1;
var output = "";
var vocab = "";
var stop_phrase = "";
var wrap = false;
var comments = true;

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

function expand(e, letters, acks) {
  var letter = letters[e];
  if (letter && letter.media) {
    acks[letter.media] = letter;
    return {v: "<img src='" + letter.media + "'/>"};
  }
  var vs = e.split(":");
  var afterPlain = false;
  var txt = "";
  if (vs.length > 1) {
    for (var j=0; j<vs.length; j++) {
      var v = vs[j];
      var ri = expand(v, letters, acks);
      if (afterPlain) { txt += ':'; }
      txt += ri.v;
      afterPlain = ri.plain;
    }
    return {v: txt, plain: afterPlain};
  }
  if (e === ' ') {
    return {v: "&emsp;"};
  }
  if (!letter) {
    return {v: e, plain: true};
  }
  if (letter.text) {
    return {v: letter.text};
  }
  return expand(letter.alias, letters, acks);
}

function showSpider(root,src) {
    var cos = require(root + "/src/SpiderScrawl").cosmicos;
    var ss = new cos.SpiderScrawl(null,0,0);
    var path = root + "/assets/fonts/spider/";
    if (wrap) {
	process.stdout.write("<!DOCTYPE html>\
<html lang='en'>\
  <head>\
    <meta charset='utf-8'>\
    <title>CosmicOS</title>\
<style type='text/css'>\
      @font-face { \
  font-family: 'cosmic_spider'; \
  src: url('" + path + "cosmic_spider.eot'); \
  src: url('" + path + "cosmic_spider.eot?#iefix') format('embedded-opentype'), \
       url('" + path + "cosmic_spider.woff2') format('woff2'), \
       url('" + path + "cosmic_spider.woff') format('woff'), \
       url('" + path + "cosmic_spider.ttf') format('truetype'), \
       url('" + path + "cosmic_spider.svg#cosmic_spider') format('svg'); \
} \
 .koan {\
   font-size: 32px; \
 }\
 .s {\
   color: #ccc;\
 }\
 img {\
   height: 32px; \
   vertical-align:middle; \
 }\
 body { \
  font-family: \"cosmic_spider\"; \
  font-style: normal; \
  font-weight: normal; \
  font-variant: normal; \
  word-break: break-all; \
  background: white; \
  color: blue; \
} \
 p { \
  margin: 0; \
  padding: 0; \
  padding: 5px; \
} \
</style>\
  </head>\
  <body>\
");
    }
    for (var s=stanza; s<=last_stanza; s++) {
      var m = msg[s];
      if (!m) continue;
      var code = m["code"];
      if (!code) {
	continue;
      }
      var txt = ss.addString(code);
      process.stdout.write("<p>" + txt + "</p>\n");
    }
    if (wrap) {
	process.stdout.write("\
</body>\
</html>\
");
    }
}

function showText(root,src) {
    if (wrap) {
	process.stdout.write("<!DOCTYPE html>\
<html lang='en'>\
  <head>\
    <meta charset='utf-8'>\
    <title>CosmicOS</title>\
<style type='text/css'>\
 .koan {\
   font-size: 32px; \
 }\
 .s {\
   color: #ccc;\
 }\
 img {\
   height: 32px; \
   vertical-align:middle; \
 }\
</style>\
  </head>\
  <body>\
");
    }
    var ev = require(root + "/src/CosmicEval.js").cosmicos;
    var render = new ev.ManuscriptStyle();
    var letters_src = {};
    if (vocab) {
	letters_src = require(path.resolve(process.cwd(), vocab));
    }
    var letters = {};
    if (letters_src["vocab"]) {
	var lst = letters_src["vocab"];
	for (var i=0; i<lst.length; i++) {
	    var e = lst[i];
	    letters[e.title] = e;
	}
    }

    var acks = {};
    for (var s=stanza; s<=last_stanza; s++) {
	var m = msg[s];
	if (!m) continue;
	if (stop_phrase!="") {
	    var lines = m["lines"];
	    var stop = false;
	    var skip = false;
	    for (var i=0; i<lines.length; i++) {
		if (lines[i].indexOf(stop_phrase)!=-1) {
		    stop = true;
		}
		if (lines[i].indexOf("GNU General Public License")!=-1) {
		    skip = true;
		}
	    }
	    if (stop) break;
	    if (skip) continue;
	}
	var parse = m["parse"];
	if (!parse) {
	    if (m["role"] == "comment") {
                if (!comments) { continue; }
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
	for (var i=0; i<txt.length; i++) {
	  var e = txt[i];
          var v = expand("" + e, letters, acks);
          process.stdout.write(v.v);
	}
	process.stdout.write("&nbsp;&nbsp;<span class='s'>~</span>\n</div>\n");
    }
    var lst = Object.keys(acks);
    if (lst.length>0) {
	process.stdout.write("<div class='ack'><div>Icons used under CC BY, credits:</div><ul>\n");
	for (var i=0; i<lst.length; i++) {
	    var ack = acks[lst[i]];
	    var author = ack["author"];
	    var license = ack["license"];
	    var lnk = ack["src"];
	    if (lnk) {
		if (license!="Public Domain") {
		    process.stdout.write("<li><a href='" + lnk + "'>" + author + "</a></li>\n");
		}
	    }
	}
	process.stdout.write("</ul></div>\n");
    }
    if (wrap) {
	process.stdout.write("\
</body>\
</html>\
");
    }
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
            if (last_stanza === -2 && msg.length > 0) {
              last_stanza = msg[msg.length - 1].stanza;
            }
	}
	if (argv[i-1]=="-o") {
	    output = argv[i];
	}
	if (argv[i-1]=="-s") {
	    stop_phrase = argv[i];
	}
	if (argv[i-1]=="-v") {
	    vocab = argv[i];
	}
    }
    for (var i=2; i<argv.length; i++) {
	if (argv[i]=="-w") {
	    wrap = true;
	}
	if (argv[i]=="-nc") {
	    comments = false;
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
    if (cmd == 'spider') {
	needStanza();
	showSpider(root,src);
	return 0;
    }
    if (cmd == 'hear') {
        var stream = fs.createWriteStream(output, {encoding: 'binary'});
	var cos = require(root + "/src/CosmicAudio.js").cosmicos;
	var snd = new cos.Sound();
	needStanza();
	needOutput();
	snd.textToWav("",false);
        stream.write(snd.drainWav());
        for (var s=stanza; s<=last_stanza; s++) {
          if (!msg[s]) break;
	  var c = msg[s].code;
	  if (!c) {
            console.log("Skip stanza", s);
            continue;
          }
          console.log("Stanza", s);
          snd.addText(c);
          stream.write(snd.drainWav());
        }
        stream.end();
	console.log("Wrote to " + output);
	return 0;
    }
    console.log("Welcome to the CosmicOS message inspector command. Usage:");
    console.log("  cosmsg show -p NNNN                  # show info about message part NNNN");
    console.log("  cosmsg hear -p NNNN -o audio.wav     # convert message part to audio");
    console.log("  cosmsg text -p NNNN -v vocab.json    # experimental text rendering of message part NNNN");
    console.log("  cosmsg text -p NFIRST -P NLAST -s 'stop phrase' -v vocab.json -w -nc");
    console.log("  cosmsg spider -p NFIRST -P NLAST -w  # spider font rendering of message");
}



