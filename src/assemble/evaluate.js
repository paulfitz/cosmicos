var CosmicDrive = require('CosmicDrive');
var cosmicos = new CosmicDrive({
    'primer': true,
    'txt': true
});

var all = cosmicos.get_message();

var err_part = null;
var err_i = -1;
var line_limit = cosmicos.config.lines();
try {
    for (var i=0; i<all.length && (i<line_limit || line_limit==0); i++) {
	var part = all[i];
	err_part = part;
	err_i = i;
	if (part.role != "code") continue;
	var op = part.lines.join("\n");
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

        var v = cosmicos.complete_stanza(part, !skippy);
	if (v!=1) {
	    throw v;
	}
    }
} catch (e) {
  process.stderr.write("* evaluate.js failed on " + err_i + ": " + JSON.stringify(err_part) + "\n");
  console.error("Error", e);
  throw(e);
}


var ct = 0;
for (var i=0; i<all.length; i++) {
    var splitter = /^# ([A-Z][A-Z]+) (.*)/;
    var part = all[i];
    if (part.role !== "comment" && part.role !== "doc") continue;
    if (part.lines.length==0) continue;
    var match = splitter.exec(part.lines[0]);
    if (match == null) continue;
    part["section_description"] = match[2];
    part["section_category"] = match[1];
    part["section_index"] = ct;
    part["lines"] = part["lines"].slice(1);
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

cosmicos.add_line_numbers();

var fs = require('fs');
fs.writeFileSync('q.txt', cosmicos.get_coded_message());
fs.writeFileSync('assem2.json',JSON.stringify(all, null, 2));
