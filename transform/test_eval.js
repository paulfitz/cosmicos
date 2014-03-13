#!/usr/bin/env node

var assert = require("assert");
var cos = require("CosmicEval").cosmicos;
var ev = new cos.Evaluate();
ev.addStd();
assert.equal(ev.evaluateLine("(? x / * $x 2) 12"),24);
