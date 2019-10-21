#!/usr/bin/env node

const cos = require("./cosmic");

cos.language(2);
cos.seed(42);

cos.intro("map");
cos.add(`
define map | ? x:? | ? x:list |
  if (= 0 | list-length $x:list) (list 0) |
  prepend (x:? | head $x:list) (map $x:? | tail $x:list)`);

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

cos.intro("reduce");
cos.add(`
define reduce | ? x:? | ? x:list |
  if (= 0 | list-length $x:list) $undefined |
  if (= 1 | list-length $x:list) (head $x:list) |
  x:? (head $x:list) (reduce $x:? | tail $x:list)`);

for (let i = 0; i < 4; i++) {
  const lst = cos.prand(20, i + 3);
  const out = lst.reduce((a, b) => a + b);
  cos.add(`= ${out} | reduce $+ | ${cos.listExpression(lst)}`);
}
