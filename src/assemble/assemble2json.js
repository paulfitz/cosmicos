var fs = require('fs');

var all = [];
var cache = [];
var expecting = /:/;
var role = "";
var role_flush = "";
var coding = false;
var markdown = false;

function emit(txt) {
    // deal with markdown
    if (txt.indexOf('[[[') === 0) {
        markdown = true;
        all.push({
	  "role": role,
	  "lines": cache
        });
        cache = [];
        return;
    }
    if (txt.indexOf(']]]') === 0) {
        markdown = false;
        all.push({
	  "role": "doc",
	  "lines": cache
        });
        cache = [];
        return;
    }
    if (markdown) {
      cache.push(txt);
      return;
    }
    var need_flush = false;
    var blank = (!(/[^ \t]/.test(txt)));
    if (coding) blank = false;
    if (blank) {
	need_flush = true;
	role_flush = role;
	role = "code";
	expecting = /:/;
    } else {
	var ch = (txt.length>0)?txt.charAt(0):' ';
	if (role=="code") {
	    coding = !(/;/.test(txt));
	}
	if (ch!=' '&&ch!='\t'&&!expecting.test(ch)) {
	    need_flush = true;
	    role_flush = role;
	    role = "code";
	}
	if (ch=='#') { 
	  expecting = /\#/;
	  role = "comment";
        } else if (ch === '~') {
	  expecting = /~/;
	  role = "doc";
	} else if (ch=='>' && txt.length>=3 && txt.charAt(1)=='>' && txt.charAt(2)=='>') {
	    expecting = /[>0-9]/;
	    role = "gate";
	} else {
	    if (ch=='=' && txt.length>=3 && txt.charAt(1)=='=' && txt.charAt(2)==' ') {
		role = "file";
	    }
	    if (need_flush) expecting = /:/;
	}
    }
    if (need_flush) {
	if (cache.length>0) {
	    var jn = cache.join(" ");
	    var len = jn.length;
	    if (len>3) {
		if (jn.charAt(0)=="("&&jn.charAt(len-1)==";"&&jn.charAt(len-2)==")") {
		    var at = 0;
		    for (var k=1; k<len-2; k++) {
			var ch = jn.charAt(k);
			if (ch=='('||ch=='{') at++;
			if (ch==')'||ch=='}') at--;
			if (at<0) break;
		    }
		    if (at>=0) {
			cache[0] = cache[0].substr(1);
			var alt = cache.length-1;
			cache[alt] = cache[alt].substr(0,cache[alt].length-2) + ";";
		    }
		    if (jn.indexOf("point")>=0) {
			process.stderr.write(" " + at + " // " + jn + " --> " + cache.join(" ") + "\n");
		    }
		}
	    }
          if (role_flush === 'doc') {
            if (cache.length >= 1) {
              if (cache[0].indexOf('~ ') === 0) {
                // markdown comment
                role_flush = "doc";
                for (var i=0; i<cache.length; i++) {
                  cache[i] = cache[i].slice(2);
                }
              }
            }
          }
	    all.push({
		"role": role_flush,
		"lines": cache
	    });
	}
	cache = [];
	coding = false;
    }
    if (!blank) {
	cache.push(txt.replace(/\t/g,"    "));
    }
}

fs.readFile(process.argv[2], function(err,data) {
    if (err) throw err;
    console.log("OK");
    data = "" + data + "\n";
    var lst = data.split(/\n/);
    console.log(lst.length + " lines");
    for (var i=0; i<lst.length; i++) {
	emit(lst[i]);
    }
    console.log(all.length + " blocks");
    var fname = "assem.json";
    fs.writeFile(fname, JSON.stringify(all, null, 2), function(err) {
	if(err) {
	    console.log(err);
	} else {
	    console.log("JSON saved to " + fname);
	}
    }); 
});
