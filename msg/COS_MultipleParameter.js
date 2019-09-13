#!/usr/bin/env node
const cos = require('./cosmic');

cos.comment("SYNTAX lambda functions");
cos.add("intro lambda");
cos.add("define prev-translate $translate");
cos.add(`
define translate |
  let ((prev $prev-translate)) |
  ? x |
    if (single? $x) (prev $x) |
    if (not | = lambda | head $x) (prev $x) |
    let ((formals | head | tail $x)
         (body | head | tail | tail $x)) |
      if (= 0 | list-length $formals) (translate $body) |
      translate | vector lambda (except-last $formals) |
        vector ? (last $formals) $body`);

for (let i = 0; i < 5; i++) {
  const r2 = cos.irand(10);
  const r1 = cos.irand(10) + r2;
  cos.add(`= ${r1 - r2} | (lambda (x y) | - $x $y) ${r1} ${r2}`);
}
