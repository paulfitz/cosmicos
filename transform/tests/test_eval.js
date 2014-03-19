#!/usr/bin/env node

var assert = require("assert");
var cos = require("CosmicEval").cosmicos;
var ev = new cos.Evaluate();
ev.addStd();

assert.equal(ev.evaluateLine("(? x / * $x 2) 12"),24);

{
    var lst = ev.numberizeLine("5");
    console.log(lst);
}

{
    var lst = ev.numberizeLine("+ +-in-unary / (+ 0 / + 0 U111U)");
    console.log(lst);
    var str = cos.Parse.codify(lst);
    console.log(str);
    cos.Parse.removeSlashMarker(lst);
    console.log(lst);
}


{
    ev.applyOldOrder();
    var lst = ev.numberizeLine("intro-in-unary U1U;");
    console.log(lst);
    var str = cos.Parse.codify(lst);
    console.log(str);
    cos.Parse.removeSlashMarker(lst);
    console.log(lst);
}
