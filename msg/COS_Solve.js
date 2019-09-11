#!/usr/bin/env node

var cos = require("./cosmic");

cos.doc("# MATH introduce solving");

cos.add("intro solve");

cos.add("= 5 | solve | ? x | = $x 5");
cos.add("= 9 | solve | ? x | = 10 | + $x 1");
cos.add("= 2 | solve | ? x | and (= 4 | * $x $x) (> $x 0)");
cos.add("= (minus 2) | solve | ? x | and (= 4 | * $x $x) (< $x 0)");

cos.add("intro sqrt");
cos.add("= 2 | * (sqrt 2) (sqrt 2)");
cos.add("= (sqrt 2) | solve | ? x | and (> $x 0) (= 2 | * $x $x)");

cos.add("= 2 | + (frac 3 2) (frac 1 2)");

cos.add("= (minus 1) | * $i $i");
