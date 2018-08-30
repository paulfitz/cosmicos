#!/usr/bin/env node

var path = require('path');

var binaryDir = path.resolve(__dirname, '..');
var delta = path.relative('@CMAKE_BINARY_DIR@', '@CMAKE_SOURCE_DIR@');
var sourceDir = path.resolve(binaryDir, delta);

var cos = require(path.resolve(sourceDir, 'src/assemble/cosmicos.js'));
return cos(binaryDir,sourceDir);
