var cos = require("./cosmic");
cos.language(2);
cos.seed(42);

cos.section("show some syntax variants","MATH");

cos.add(["=", 6, 6]);
cos.add(["=", 6, ["+", 1, 5]]);
cos.add(["=", 6, [-1, "+", 1, 5]]);
cos.add(["=", 6, [-1, "+", 1, ["+", 4, 1]]]);
cos.add(["=", 6, [-1, "+", 1, [-1, "+", 4, 1]]]);
cos.add(["=", 6, ["+", 1, 5]]);
cos.add(["=", ["+", 3, 3], ["+", 1, 5]]);
cos.add(["=", ["+", 3, ["-", 5, 2]], ["+", 1, 5]]);
cos.add(["=", ["+", 3, [-1, "-", 5, 2]], ["+", 1, 5]]);
cos.add(["=", ["+", 3, [-1, "-", 5, 2]], [-1, "+", 1, 5]]);

cos.section("show local assignment","MATH");

cos.add("assign x 1 | = (x) 1");
cos.add("assign x 2 | = (x) 2");
cos.add("assign x 3 | = (x) 3");
cos.add("assign x 3 | = 9 (* (x) (x))");
cos.add("assign x 4 | = 16 (* (x) (x))");
cos.add("assign x (+) | = 7 (x 4 3)");
cos.add("assign x (+) | = 12 (x 6 6)");
cos.add("assign x (+) | = 9 (x 7 2)");
cos.add("assign x (-) | = 1 (x 4 3)");
cos.add("assign x (-) | = 0 (x 6 6)");
cos.add("assign x (-) | = 5 (x 7 2)");
cos.add("assign x (*) | = 12 (x 4 3)");
cos.add("assign x (*) | = 36 (x 6 6)");
cos.add("assign x (*) | = 14 (x 7 2)");
cos.add("assign x (=) | x 4 4");
cos.add("assign x (=) | x 4 (+ 2 2)");
cos.add("assign x 1 | assign y 2 | = 3 (+ (x) (y))");
cos.add("assign x 2 | assign y 7 | = 5 (- (y) (x))");
cos.add("assign x (+) | assign y 3 | = 4 (x 1 (y))");

cos.comment("Scoping and other odd corners.");
cos.add("= 2 | assign x 1 | + $x 1");
cos.add("= 1 | assign x 1 $x");
cos.add("= 14 | assign x 1 14");
cos.add("= 4 | assign x (assign y 3 | + 1 $y) $x");
cos.add("= 4 | assign x (assign x 3 | + 1 $x) $x");

cos.comment("Show alternate lookup syntax.");
cos.add("assign x 1 | = (x) 1");
cos.add("assign x 1 | = $x 1");
cos.add("assign x 4 | = 16 (* (x) (x))");
cos.add("assign x 4 | = 16 (* $x $x)");
cos.add("assign x 4 | = 16 | * $x $x");

cos.comment("Now for functions.");
var top = 6;
for (var i=0; i<top; i++) {
    cos.add("= " + i +" | (? x $x) " + i);
}
for (var i=0; i<top; i++) {
    cos.add("= " + (i+1) +" | (? x | + 1 $x) " + i);
}
for (var i=0; i<top; i++) {
    cos.add("= " + (i*i) +" | (? x | * $x $x) " + i);
}
for (var i=0; i<top; i++) {
    cos.add("= " + (i*i) +" | (? y | * $y $y) " + i);
}
cos.comment("Throw in a little mind-boggle.");
for (var i=0; i<top; i++) {
    cos.add("= " + (i*i) +" | (? + | * $+ $+) " + i);
}
for (var i=0; i<top; i++) {
    cos.add("= " + (i*i) +" | (? 5 | * $5 $5) " + i);
}

cos.comment("Functions in a box.");
cos.add("assign x (? y | * $y $y) | = 25 | x 5");
cos.add("assign x (? y | + $y 1) | = 6 | x 5");
cos.add("assign x (? x | + $x 1) | = 6 | x 5");
cos.add("assign y (? x | + $x 1) | = 6 | y 5");

cos.comment("Serve some curry.");
cos.add("= 52 | * 4 13");
cos.add("= 52 | (? x | * $x 4) 13");
cos.add("= 52 | (? x | ? y | * $x $y) 13 4");
cos.add("= 53 | (? x | ? y | + 1 | * $x $y) 13 4");
cos.add("assign z (? x | ? y | + 1 | * $x $y) | = 53 | z 13 4");
