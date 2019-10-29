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
  if (<= $x:+ $x:-) (vector) |
  prepend $x:- | range (+ 1 $x:-) $x:+`);
cos.add("= 6 | reduce $+ | range 0 4");
cos.add("= 12 | reduce $+ | map (? x | * $x 2) | range 0 4");
cos.add("= 3 | reduce $+ | range 3 4");

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
cos.add("within $demo:epsilon (frac 1 3) | decimal 0 | vector 3 3 3 3 3 3");
cos.add("within $demo:epsilon (frac 9 7) | decimal 1 | vector 2 8 5 7 1 4");

cos.add("intro e");
cos.add("define e:hat | reduce $+ | map (? x | frac 1 | factorial $x) | range 0 100");
cos.add("within $demo:epsilon $e $e:hat");
cos.add("within $demo:epsilon $e | decimal 2 | vector 7 1 8 2 8")

cos.add("intro pi");
cos.add("define pi:part | ? x | frac (if (even $x) (minus 1) 1) | * (* $x 2) | * (+ 1 | * $x 2) (+ 2 | * $x 2)");
cos.add("define pi:hat | + 3 | * 4 | reduce $+ | map $pi:part | range 1 100");
cos.add("within $demo:epsilon $pi $pi:hat");
cos.add("within $demo:epsilon $pi | decimal 3 | vector 1 4 1 5 9 2 6 5 3 5");

cos.add("intro power:10");
cos.add(`define power:10 | ? n |
  if (= $n 0) 1 |
  assign part (if (>= $n 0) 10 (frac 1 10)) |
  reduce $* | map (? x $part) | range 0 (abs $n)`);

cos.add(`define float:= | ? x | ? y |
  if (= $x $y) $true |
  within (frac (+ $x $y) 200000) $x $y`);
cos.add(`float:= 10 | power:10 1`);
cos.add(`float:= 100 | power:10 2`);
cos.add(`float:= 1000 | power:10 3`);
cos.add(`float:= (frac 1 10) | power:10 | minus 1`);
cos.add(`float:= (frac 1 100) | power:10 | minus 2`);
cos.add(`float:= 1 | power:10 0`);

cos.add(`define decimal:power | ? x:power | ? x:int | ? x:list |
  * (power:10 $x:power) (decimal $x:int $x:list)`);

cos.add(`float:= 1530 | decimal:power 3 1 | vector 5 3`);
cos.add(`float:= 15300 | decimal:power 4 1 | vector 5 3`);
cos.add(`float:= (decimal 1 | vector 5 3) | decimal:power 0 1 | vector 5 3`);
cos.add(`float:= (decimal 0 | vector 0 0 1 5 3) | decimal:power (minus 3) 1 | vector 5 3`);

cos.intro('pow:int');
cos.add(`define pow:int | ? x | ? n |
  if (= $n 0) 1 |
  assign part (if (>= $n 0) $x (frac 1 $x)) |
  reduce $* | map (? y $part) | range 0 (abs $n)`);

cos.add(`= 100 | pow:int 10 2`);
cos.add(`= 25 | pow:int 5 2`);
cos.add(`= 4 | pow:int 2 2`);
cos.add(`= 8 | pow:int 2 3`);
cos.add(`= 16 | pow:int 2 4`);
cos.add(`= 1 | pow:int 2 0`);
cos.add(`= (frac 1 2) | pow:int 2 | minus 1`);

cos.intro('pow');

for (let i=2; i<=5; i++) {
  for (let j=0; j<5; j++) {
    cos.add(`= ${Math.pow(i, j)} | pow ${i} ${j}`);
  }
}

for (let i=2; i<=4; i++) {
  for (let j=0; j<=12; j++) {
    const jj = j / 4.0;
    const result = cos.decimal(Math.pow(i, jj), 5, true);
    const exponent = cos.decimal(jj, 5, true);
    cos.add(`float:= ${result} | pow ${i} ${exponent}`);
  }
}

cos.intro(`exp`);
// I've lazily let this be order squared.
cos.add(`define exp:hat | ? x |
  reduce $+ | map (? n | frac (pow:int $x $n) | factorial $n) | range 0 50`);

cos.add(`float:= $e | exp:hat 1`);

cos.add(`define ln:10:hat | decimal 2 | vector 3 0 2 5 8 5 0 9 2 9 9`);
cos.add(`float:= (pow:int 10 2) (exp:hat | * 2 $ln:10:hat)`);
cos.add(`float:= (pow:int 10 3) (exp:hat | * 3 $ln:10:hat)`);
cos.add(`float:= (pow:int 10 4) (exp:hat | * 4 $ln:10:hat)`);
