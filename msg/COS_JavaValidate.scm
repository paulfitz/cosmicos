
# JAVA check that automatic conversion is workable


(define test1 | COS_JavaTest new);

# Note that the names of methods include type information.
# This could easily be removed, but is retained so that overloading
# is possible in the Java code.
# I is integer, V is void.  The last type in the name is the return type.

(= (test1 mult-I-I-I 15 10) 150);

# The type information can be safely omitted if there is no ambiguity
(= (test1 mult 15 10) 150);

(= (test1 addmult-I-I-I-I 4 15 10) 154);

(begin
  (test1 set-I-V 87)
  (= (test1 get-I) 87));

(= (test1 fact-I-I 0) 1);

(= (test1 fact-I-I 1) 1);

(= (test1 fact-I-I 5) 120);

# Yay! testing says this works.
# So structure for bytecode interpretation is in place.
# Very few opcodes actually implemented yet though.


