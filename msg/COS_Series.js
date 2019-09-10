#!/usr/bin/env node

var cos = require("./cosmic");

cos.add("intro minus");
cos.add("define minus | ? x | - 0 $x");
cos.add("= 0 | + 4 | minus 4");
cos.add("= 8 | + 10 | minus 2"); 

cos.add("intro frac");
cos.add("= 40 | frac 40 1");
cos.add("= 20 | frac 40 2");
cos.add("= 10 | frac 40 4");
cos.add("= 5 | frac 40 8");
cos.add("= 1 | + (frac 1 2) (frac 1 2)");
cos.add("= 2 | + (frac 3 2) (frac 1 2)");
cos.add("= 1 | + (frac 3 5) (frac 2 5)");

cos.add("intro abs");
cos.add("define abs | ? x | if (> $x 0) $x (- 0 $x)");
cos.add("= 4 | abs 4")
cos.add("= 4 | abs | minus 4");

cos.add("intro within");
cos.add("define epsilon | frac 1 10000");
cos.add("define within | ? t | ? x | ? y | < (abs | - $x $y) $t");
cos.add("not | within $epsilon 1 2");
cos.add("not | within $epsilon 2 1");
cos.add("within $epsilon 2 2");
cos.add("within $epsilon 2 | + 2 (frac $epsilon 2)");
cos.add("not | within $epsilon 2 | + 2 (* $epsilon 2)");

cos.add("intro range");
cos.add(`
define range | ? lo | ? hi |
  if (<= $hi $lo) (list 0) |
  prepend $lo | range (+ 1 $lo) $hi`);
cos.add("= 6 | crunch $+ | range 0 4");
cos.add("= 12 | crunch $+ | map (? x | * $x 2) | range 0 4");

cos.add("intro even");
cos.add("define even | ? x | = 0 | - $x | * 2 | div $x 2");
cos.add("not | even 1");
cos.add("even 2");
cos.add("not | even 3");
cos.add("even 4");
cos.add("not | even 5");
cos.add("intro odd");
cos.add("define odd | ? x | not | even $x");
cos.add("odd 1");
cos.add("even 2");
cos.add("odd 3");
cos.add("even 4");
cos.add("odd 5");

cos.add("intro decimal");
cos.add(`
define float | ? lst | ? f | ? v |
  if (= 0 | list-length | $lst ) 0 |
  + (* $v | head $lst) |
  float (tail $lst) $f (* $f $v)`);
cos.add("define decimal | ? i | ? lst | + $i | float $lst (frac 1 10) (frac 1 10)");
cos.add("within $epsilon (frac 1 3) | decimal 0 | (list 6) 3 3 3 3 3 3");
cos.add("within $epsilon (frac 9 7) | decimal 1 | (list 6) 2 8 5 7 1 4");

cos.add("intro e");
cos.add("define e-hat | crunch $+ | map (? x | frac 1 | factorial $x) | range 0 100");
cos.add("within $epsilon $e $e-hat");
cos.add("within $epsilon $e | decimal 2 | (list 5) 7 1 8 2 8")

cos.add("intro pi");
cos.add("define pi-term | ? x | frac (if (even $x) (minus 1) 1) | * (* $x 2) | * (+ 1 | * $x 2) (+ 2 | * $x 2)");
cos.add("define pi-hat | + 3 | * 4 | crunch $+ | map $pi-term | range 1 100");
cos.add("within $epsilon $pi $pi-hat");
cos.add("within $epsilon $pi | decimal 3 | (list 10) 1 4 1 5 9 2 6 5 3 5");
