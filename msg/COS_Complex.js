#!/usr/bin/env node

var cos = require("./cosmic");

cos.doc("# MATH introduce i");
cos.doc("A very very abbreviated introduction of complex numbers");

cos.add(`
define all-equal | ? lst |
  if (>= 1 | list-length $lst) $true |
  and (= (list-ref $lst 0) (list-ref $lst 1))
      (all-equal | tail $lst)`);
cos.add("all-equal | vector 2 2 2");
cos.add("not | all-equal | vector 2 2 1");
cos.add("not | all-equal | vector 2 1 2");
cos.add("not | all-equal | vector 1 2 2");

cos.add("define sum | crunch $+");

cos.add("intro i");
cos.add("= (minus 1) | * $i $i");

cos.add("define complex | ? x | ? y | + $x | * $y $i");

cos.add("= (complex 5 6) | + (complex 3 2) (complex 2 4)");

cos.add("= (complex 7 22) | * (complex 5 4) (complex 3 2)");

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
