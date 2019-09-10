#!/usr/bin/env node

const cos = require("./cosmic");

cos.language(2);
cos.seed(42);

cos.add(`
define map | ? p | ? lst |
  if (= 0 | list-length $lst) (list 0) |
  prepend (p | head $lst) (map $p | tail $lst)`);

for (let i = 0; i < 4; i++) {
  const lst = cos.prand(20, i + 3);
  const out = lst.map(v => 2 * v);
  cos.add(`list= (${cos.listExpression(out)}) | map (? x | * $x 2) | ${cos.listExpression(lst)}`);
}

for (let i = 0; i < 4; i++) {
  const lst = cos.prand(20, i + 3);
  const out = lst.map(v => 42);
  cos.add(`list= (${cos.listExpression(out)}) | map (? x 42) | ${cos.listExpression(lst)}`);
}

cos.add(`
define crunch | ? p | ? lst |
  if (= 0 | list-length $lst) $undefined |
  if (= 1 | list-length $lst) (head $lst) |
  p (head $lst) (crunch $p | tail $lst)`);

for (let i = 0; i < 4; i++) {
  const lst = cos.prand(20, i + 3);
  const out = lst.reduce((a, b) => a + b);
  cos.add(`= ${out} | crunch $+ | ${cos.listExpression(lst)}`);
}
