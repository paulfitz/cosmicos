#!/usr/bin/env node
const cos = require('./cosmic');

cos.comment("SYNTAX lambda functions");
cos.add("intro lambda");
cos.add("define translate:lambda:begin $translate");
cos.add(`
define translate |
  let ((x:translate $translate:lambda:begin)) |
  ? x |
    if (not | function? $x) (x:translate $x) |
    if (not | = lambda | head $x) (x:translate $x) |
    let ((x:list | head | tail $x)
         (y | head | tail | tail $x)) |
      if (= 0 | list-length $x:list) (translate $y) |
      translate | vector lambda (except-last $x:list) |
        vector ? (last $x:list) $y`);

for (let i = 0; i < 5; i++) {
  const r2 = cos.irand(10);
  const r1 = cos.irand(10) + r2;
  cos.add(`= ${r1 - r2} | (lambda (x y) | - $x $y) ${r1} ${r2}`);
}
