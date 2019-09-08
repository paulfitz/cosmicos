#!/usr/bin/env node

var cos = require("./cosmic");

cos.doc("# MATH introduce solving");

cos.add("intro solve");

cos.add("define minus | ? x | - 0 $x");
cos.add("= 5 | solve | ? x | = $x 5");
cos.add("= 9 | solve | ? x | = 10 | + $x 1");
cos.add("= 2 | solve | ? x | and (= 4 | * $x $x) (> $x 0)");
cos.add("= (minus 2) | solve | ? x | and (= 4 | * $x $x) (< $x 0)");

cos.add("intro sqrt");
cos.add("= 2 | * (sqrt 2) (sqrt 2)");
cos.add("= (sqrt 2) | solve | ? x | and (> $x 0) (= 2 | * $x $x)");

cos.add("= 2 | + (frac 3 2) (frac 1 2)");

cos.add("define epsilon | frac 1 10000");
cos.add("define abs | ? x | if (> $x 0) $x (- 0 $x)");
cos.add("= 4 | abs 4")
cos.add("= 4 | abs | minus 4");
cos.add("define near | ? x | ? y | < (abs | - $x $y) $epsilon");
cos.add("not | near 1 2");
cos.add("not | near 2 1");
cos.add("near 2 2");
cos.add("near 2 | + 2 (frac $epsilon 2)");
cos.add("not | near 2 | + 2 (* $epsilon 2)");

cos.add("define range | ? lo | ? hi | if (<= $hi $lo) (vector) | prepend $lo (range (+ 1 $lo) $hi)");
cos.add("= 6 | crunch $+ | range 0 4");
cos.add("= 12 | crunch $+ | map (? x | * $x 2) | range 0 4");

cos.add("define e-ish | crunch $+ | map (? x | frac 1 | factorial $x) | range 0 100");
// cos.add("e-ish");

cos.add("intro e");
cos.add("near $e $e-ish");

cos.add("define even | ? x | = 0 | - $x | * 2 | div $x 2");
cos.add("not | even 1");
cos.add("even 2");
cos.add("not | even 3");
cos.add("even 4");
cos.add("not | even 5");

cos.add("define pi-term | ? x | frac (if (even $x) (minus 1) 1) | * (* $x 2) | * (+ 1 | * $x 2) (+ 2 | * $x 2)");

cos.add("define pi-ish | + 3 | * 4 | crunch $+ | map $pi-term | range 1 100");
cos.add("near $pi $pi-ish");

cos.add("= (minus 1) | * $i $i");
