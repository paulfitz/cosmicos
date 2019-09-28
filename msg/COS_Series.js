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
cos.add("define demo:epsilon | frac 1 10000");
cos.add("define within | ? epsilon | ? x | ? y | < (abs | - $x $y) $epsilon");
cos.add("not | within $demo:epsilon 1 2");
cos.add("not | within $demo:epsilon 2 1");
cos.add("within $demo:epsilon 2 2");
cos.add("within $demo:epsilon 2 | + 2 (frac $demo:epsilon 2)");
cos.add("not | within $demo:epsilon 2 | + 2 (* $demo:epsilon 2)");

cos.add("intro range");
cos.add(`
define range | ? x:- | ? x:+ |
  if (<= $x:+ $x:-) (list 0) |
  prepend $x:- | range (+ 1 $x:-) $x:+`);
cos.add("= 6 | reduce $+ | range 0 4");
cos.add("= 12 | reduce $+ | map (? x | * $x 2) | range 0 4");

cos.add("intro even");
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
define float | ? x:list | ? y | ? z |
  if (= 0 | list-length | $x:list) 0 |
  + (* $z | head $x:list) |
  float (tail $x:list) $y (* $y $z)`);
cos.add("define decimal | ? x | ? x:list | + $x | float $x:list (frac 1 10) (frac 1 10)");
cos.add("within $demo:epsilon (frac 1 3) | decimal 0 | (list 6) 3 3 3 3 3 3");
cos.add("within $demo:epsilon (frac 9 7) | decimal 1 | (list 6) 2 8 5 7 1 4");

cos.add("intro e");
cos.add("define e:hat | reduce $+ | map (? x | frac 1 | factorial $x) | range 0 100");
cos.add("within $demo:epsilon $e $e:hat");
cos.add("within $demo:epsilon $e | decimal 2 | (list 5) 7 1 8 2 8")

cos.add("intro pi");
cos.add("define pi:part | ? x | frac (if (even $x) (minus 1) 1) | * (* $x 2) | * (+ 1 | * $x 2) (+ 2 | * $x 2)");
cos.add("define pi:hat | + 3 | * 4 | reduce $+ | map $pi:part | range 1 100");
cos.add("within $demo:epsilon $pi $pi:hat");
cos.add("within $demo:epsilon $pi | decimal 3 | (list 10) 1 4 1 5 9 2 6 5 3 5");
