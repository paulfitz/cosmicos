var fs = require('fs');

var all = [];
var cache = [];
var expecting = /:/;
var role = "";
var role_flush = "";

function emit(txt) {
    var need_flush = false;
    var blank = (!(/[^ \t]/.test(txt)));
    if (blank) {
	need_flush = true;
	role_flush = role;
	role = "code";
	expecting = /:/;
    } else {
	var ch = txt.charAt(0);
	if (ch!=' '&&ch!='\t'&&!expecting.test(ch)) {
	    need_flush = true;
	    role_flush = role;
	    role = "code";
	}
	if (ch=='#') { 
	    expecting = /\#/;
	    role = "comment";
	} else if (ch=='>' && txt.length>=3 && txt.charAt(1)=='>' && txt.charAt(2)=='>') {
	    expecting = /[>0-9]/;
	    role = "gate";
	} else {
	    if (ch=='=' && txt.length>=3 && txt.charAt(1)=='=' && txt.charAt(2)==' ') {
		role = "section";
	    }
	    if (need_flush) expecting = /:/;
	}
    }
    if (need_flush) {
	if (cache.length>0) {
	    all.push({
		"role": role_flush,
		"lines": cache
	    });
	}
	cache = [];
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