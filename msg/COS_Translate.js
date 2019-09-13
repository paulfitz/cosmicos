#!/usr/bin/env node

const cos = require('./cosmic');

cos.comment("SYNTAX how to change the imagined interpreter");
cos.add("intro translate");
cos.add("define base-translate $translate");
cos.add("define translate | ? x | if (= $x 32) 64 | base-translate $x");
cos.add("= 32 64");
cos.add("= (+ 32 64) 128");
cos.add("define translate $base-translate");
cos.add("not | = 32 64");
cos.add("= (+ 32 64) 96");

cos.doc("Now let's do something useful: define a special form for lists.");
cos.add(`
define translate | ? x |
  if (single? $x) (base-translate $x) |
  if (not | = vector | head $x) (base-translate $x) |
  translate | prepend ((list 2) list | list-length | tail $x) | tail $x`);
cos.add("list= (vector 1 2 3) | (list 3) 1 2 3");

