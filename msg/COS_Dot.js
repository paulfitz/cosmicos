#!/usr/bin/env node

const cos = require('./cosmic');

cos.intro(".");

cos.add(`define dotify:1 | ? pre | ? act | ? rem |
  if (= 0 | list-length $rem) (append $act $pre) |
  assign next (head $rem) |
  if (not | = . $next) (dotify:1 (append $act $pre) $next (tail $rem)) |
  dotify:1 $pre (vector $act | head | tail $rem) (tail | tail $rem)`);

cos.add(`define dotify | ? lst |
  dotify:1 (vector) (head $lst) (tail $lst)`);

cos.add(`list= (dotify | vector 1 2 . 3 4) (vector 1 (vector 2 3) 4)`);
cos.add(`list= (dotify | vector 1 2 . 3 . 4 5) (vector 1 (vector (vector 2 3) 4) 5)`);

cos.add(`define translate | assign prev $translate | ? x |
  if (not | function? $x) (prev $x) |
  if (<= (list-length $x) 1) (prev $x) |
  prev | dotify $x`);

cos.add(`= + . 5 . 5 10`);
cos.add(`= + . (- + . 4 . 4 3) . 5 * . 5 . 2`);
