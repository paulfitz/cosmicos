#!/usr/bin/env node

var cos = require("./cosmic");

cos.doc("# MATH introduce i");
cos.doc("A very very abbreviated introduction of complex numbers");

cos.add(`
define all-equal | ? x:list |
  if (>= 1 | list-length $x:list) $true |
  and (= (list-ref $x:list 0) (list-ref $x:list 1))
      (all-equal | tail $x:list)`);
cos.add("all-equal | vector 2 2 2");
cos.add("not | all-equal | vector 2 2 1");
cos.add("not | all-equal | vector 2 1 2");
cos.add("not | all-equal | vector 1 2 2");

cos.intro("sum");
cos.add("define sum | reduce $+");

cos.add("intro i");
cos.add("= (minus 1) | * $i $i");

cos.add("define complex | ? x | ? y | + $x | * $y $i");

cos.add("= (complex 5 6) | + (complex 3 2) (complex 2 4)");

cos.add("= (complex 7 22) | * (complex 5 4) (complex 3 2)");

cos.add("= (complex 10 8) | * (complex 5 4) 2");
cos.add("= (complex 10 8) | * 2 (complex 5 4)");

cos.doc("should work through how to divide complex numbers (multiply by conjugate)");
cos.add("= (complex (frac 6 25) (frac 17 25)) | frac (complex 3 2) (complex 4 | minus 3)");

cos.add(`
all-equal | vector
  (+ 7 | * 22 $i)
  (* (+ 5 | * 4 $i) (+ 3 | * 2 $i))
  (sum | vector
    (* 5 3)
    (* 5 (* 2 $i))
    (* (* 4 $i) 3)
    (* (* 4 $i) (* 2 $i)))
  (sum | vector
    15 (* 10 $i) (* 12 $i) (minus 8))
  (sum | vector
    (+ 15 (minus 8)) (* (+ 10 12) $i))`);

cos.doc("Hint at Euler's identity");
cos.add(`float:= 0 | + 1 | exp:hat | * $pi $i`);
