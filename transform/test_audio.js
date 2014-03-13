#!/usr/bin/env node

// First, run "haxe compile_js.hxml" to get cosmicos.js
// Then run this with NODE_PATH set to make cosmicos.js visible
// On Debian/Ubuntu: NODE_PATH=$PWD nodejs ./test.js

var cos = require("CosmicAudio").cosmicos;
var snd = new cos.Sound();
var txt = snd.textToWav("01234543210",false);

var fs = require('fs');
fs.writeFileSync("node.wav",txt,"binary");
console.log("Wrote to node.wav");
fs.writeFileSync("node.txt",snd.textToWavUrl("01234543210"),"binary");
console.log("Wrote to node.txt");

