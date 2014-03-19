var cos = require('SpiderScrawl').cosmicos;
var ss = new cos.SpiderScrawl(null,0,0);
var fs = require('fs');
fs.readFile(process.argv[2], function (err, data) {
  if (err) throw err;
    var txt = ss.addString("" + data);
    console.log(txt);
});
