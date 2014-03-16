var w = 32;
var h = 32;
var Canvas = require('canvas')
, canvas = new Canvas(w,h)
  , ctx = canvas.getContext('2d');


var cos = require('SpiderScrawl').cosmicos;
var fs = require('fs');

var todo = [];

// open = 0 or 1, closed = 0 or 1, n = 0...16 inclusive with 16 = no num
for (var open=0; open<=1; open++) {
    for (var closed=0; closed<=1; closed++) {
	for (var m=0; m<=16; m++) {
	    todo.push([open, closed, m]);
	}
    }
}

function process() {
    var t = todo.shift();
    if (t==null) return;
    var open = t[0];
    var closed = t[1];
    var m = t[2];
    var ss = new cos.SpiderScrawl(ctx,w,h,w,h);
    ctx.fillStyle = '#fff';
    ctx.fillRect(0,0,w,h);
    ctx.lineWidth = 3;
    ctx.strokeStyle = '#000';
    ss.showChar(m!=16,m,open==1,closed==1);
    var code = "" + open + closed;
    if (m!=16) {
	code += ("0000" + m.toString(2)).slice(-4);
    } else {
	code += "____";
    }
    var out = fs.createWriteStream(__dirname + '/../vectors/coschar_' + code + ".png");
    var stream = canvas.syncPNGStream();
    stream.on('data', function(chunk){
	out.write(chunk);
    });
    stream.on('end', function(){
	console.log('saved png ' + code);
	process();
    });
}

process();

