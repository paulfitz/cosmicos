#!/usr/bin/env node

// First, run "haxe compile_js.hxml" to get cosmicos.js
// Then run this with NODE_PATH set to make cosmicos.js visible
// On Debian/Ubuntu: NODE_PATH=$PWD nodejs ./test.js

var cos = require("cosmicos").cosmicos;
var snd = new cos.Sound();
var txt = snd.textToWav("01234543210",true);

var fs = require('fs');
fs.writeFileSync("node.wav",txt,"binary");
console.log("Wrote to node.wav");
