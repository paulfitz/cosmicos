#!/usr/bin/env node

const cos = require('./cosmic');

cos.add("intro let");
cos.add("define translate:let:begin $translate");
cos.add(`
define translate:let | ? x | ? y |
  if (= 0 | list-length $x) (translate $y) |
  translate:let (tail $x) |
    vector assign (head | head $x) (head | tail | head $x) $y`);
cos.add(`
define translate | ? x |
  if (not | function? $x) (translate:let:begin $x) |
  if (not | = let | head $x) (translate:let:begin $x) |
  translate:let (head | tail $x) (head | tail | tail $x)`);
cos.add("let ((x 20)) | = $x 20");
cos.add("let ((x 50) (y 20)) | = 30 | - $x $y");
cos.add("= (let ((x 10)) | + $x 5) (assign x 10 | + $x 5)")
cos.add("= (let ((x 10)) | + $x 5) ((? x | + $x 5) 10)")
cos.add("= (let ((x 10) (y 5)) | + $x $y) (assign x 10 | assign y 5 | + $x $y)");
cos.add("= (let ((x 10) (y 5)) | + $x $y) ((? x | ? y | + $x $y) 10 5)");
