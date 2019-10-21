#!/usr/bin/env node

const cos = require('./cosmic');

cos.seed(42);

cos.intro("graph:make");
cos.add(`define graph:make | lambda (x:graph:1 x:graph:2) | pair $x:graph:1 $x:graph:2`);

cos.add(`define demo:graph | graph:make
  (vector 1 2 3 4)
  (vector (pair 1 2) (pair 2 3) (pair 1 4))`);

cos.intro("exists:graph:2");
cos.add(`define exists:graph:2 | lambda (x:graph y:graph:1 z:graph:1) |
  exists | ? n |
    if (or (< $n 0) (>= $n | list-length | list-ref $x:graph 1)) $false |
    list= (list-ref (list-ref $x:graph 1) $n) (pair $y:graph:1 $z:graph:1)`);

cos.add(`exists:graph:2 $demo:graph 1 2`);
cos.add(`not | exists:graph:2 $demo:graph 1 3`);
cos.add(`not | exists:graph:2 $demo:graph 2 4`);
cos.add(`exists:graph:2 $demo:graph 1 4`);

cos.intro("exists:graph:2:list");
cos.add(`define exists:graph:2:list | lambda (x:graph y:graph:1 z:graph:1) |
  if (= $y:graph:1 $z:graph:1) $true |
  if (exists:graph:2 $x:graph $y:graph:1 $z:graph:1) $true |
  exists | ? n:graph:1 |
    if (not | exists:graph:2 $x:graph $y:graph:1 $n:graph:1) $false |
    exists:graph:2:list $x:graph $n:graph:1 $z:graph:1`);

cos.add(`exists:graph:2:list $demo:graph 1 2`);
cos.add(`exists:graph:2:list $demo:graph 1 3`);
cos.add(`not | exists:graph:2:list $demo:graph 2 4`);
