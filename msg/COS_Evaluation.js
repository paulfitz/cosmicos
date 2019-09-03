var cos = require("./cosmic");
cos.language(2);
cos.seed(42);

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

cos.doc("An expression starting with `assign` is a way to name values for use " +
        "within that expression. " +
        "To use the assigned value, simply place its name at the beginning " +
        "of an expression.  For example, a value assigned to `x` can be used by " +
        "writing `(x)`. " +
        "The name is entirely arbitrary, and can be just an integer.");

cos.add("assign x 1 | = (x) 1");
cos.add("assign x 2 | = (x) 2");
cos.add("assign x 3 | = (x) 3");
cos.add("assign y 1 | = (y) 1");
cos.add("assign y 2 | = (y) 2");
cos.add("assign y 3 | = (y) 3");
cos.add("assign x 3 | = 9 (* (x) (x))");
cos.add("assign x 4 | = 16 (* (x) (x))");
cos.add("assign z 3 | = 9 (* (z) (z))");
cos.add("assign z 4 | = 16 (* (z) (z))");
cos.add("assign x (+) | = 7 (x 4 3)");
cos.add("assign y (+) | = 12 (y 6 6)");
cos.add("assign z (+) | = 9 (z 7 2)");
cos.add("assign a (-) | = 1 (a 4 3)");
cos.add("assign b (-) | = 0 (b 6 6)");
cos.add("assign c (-) | = 5 (c 7 2)");
cos.add("assign z (*) | = 12 (z 4 3)");
cos.add("assign y (*) | = 36 (y 6 6)");
cos.add("assign x (*) | = 14 (x 7 2)");
cos.add("assign x (=) | x 4 4");
cos.add("assign x (=) | x 4 (+ 2 2)");
cos.add("assign x 1 | assign y 2 | = 3 (+ (x) (y))");
cos.add("assign x 2 | assign y 7 | = 5 (- (y) (x))");
cos.add("assign x (+) | assign y 3 | = 4 (x 1 (y))");

cos.doc("We are pretty ruthless about adding syntax to reduce parentheses.  So let's " +
        "allow writing `(x)` as `$x` (or equivalent in other renderings).  This and `|` are " +
        "in fact global options for the message that you can turn off if they are not to " +
        "your taste.");

cos.add("assign x 1 | = (x) 1");
cos.add("assign x 1 | = $x 1");
cos.add("assign x 4 | = 16 (* (x) (x))");
cos.add("assign x 4 | = 16 (* $x $x)");
cos.add("assign x 4 | = 16 | * $x $x");

cos.doc("Add more examples to give hints about scoping and other odd corners.");

cos.add("= 2 | assign x 1 | + $x 1");
cos.add("= 1 | assign x 1 $x");
cos.add("= 14 | assign x 1 14");
cos.add("= 4 | assign x (assign y 3 | + 1 $y) $x");
cos.add("= 4 | assign x (assign x 3 | + 1 $x) $x");

cos.doc("We're ready for functions.  `?` starts a lambda function.  Now we can have fun!");

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
cos.doc("Emphasize the arbitrary nature of names, and hint that things we've learned already " +
        "like addition could possibly be re-imagined as a named value.");

for (var i=0; i<top; i++) {
    cos.add("= " + (i*i) +" | (? + | * $+ $+) " + i);
}
for (var i=0; i<top; i++) {
    cos.add("= " + (i*i) +" | (? 5 | * $5 $5) " + i);
}

cos.doc("Show that we can name functions and use them later - still within a single expression " +
        "for now.");
cos.add("assign x (? y | * $y $y) | = 25 | x 5");
cos.add("assign x (? y | + $y 1) | = 6 | x 5");
cos.add("assign x (? x | + $x 1) | = 6 | x 5");
cos.add("assign y (? x | + $x 1) | = 6 | y 5");

cos.doc("Show that we can nest functions to take multiple values.");
cos.add("= 52 | * 4 13");
cos.add("= 52 | (? x | * $x 4) 13");
cos.add("= 52 | (? x | ? y | * $x $y) 13 4");
cos.add("= 53 | (? x | ? y | + 1 | * $x $y) 13 4");
cos.add("assign z (? x | ? y | + 1 | * $x $y) | = 53 | z 13 4");
