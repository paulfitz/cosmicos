var cos = require('OghamStyle').cosmicos;
var ss = new cos.OghamStyle();
var fs = require('fs');
fs.readFile(process.argv[2], function (err, data) {
  if (err) throw err;
    var txt = ss.addString("" + data);
    console.log(txt);
});
