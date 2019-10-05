#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowHashLesson {
  my $txt = "";
  $txt .= "# MATH introduce environment/hashmap structure\n";
  $txt .= "# this section needs a LOT more examples :-)\n";
  $txt .= "# note that at the time of writing (h 1 2) is same as ((h) 1 2)\n";
  $txt .= ShowLine(Op2("define",
		       "hash-add",
		       ProcMultiple(["x:hash","x","y","z"],
				    Op("if",
				       Op2("equal",Ref("z"),Ref("x")),
				       Ref("y"),
				       Op("x:hash", Ref("z"))))));
  $txt .= ShowLine(Op2("define",
		       "hash-ref",
		       ProcMultiple(["x:hash","x"],
				    Op("x:hash", Ref("x")))));

  $txt .= ShowLine(Op2("define",
		       "hash-null",
		       Proc("x",Ref("undefined"))));
  
  $txt .= ShowLine(Op2("define",
		       "hash-default",
		       Proc("default",
			    Proc("x",Ref("default")))));
  
  $txt .= ShowLine(Op2("define",
		       "demo:hash",
		       Op("hash-add",
			  Op("hash-add",
			     Ref("hash-null"),
			     3, 2),
			  4,
			  9)));

  $txt .= ShowLine(Op2("=",
		       Op("hash-ref",
			  Ref("demo:hash"),
			  4),
		       9));
			
  $txt .= ShowLine(Op2("=",
		       Op("hash-ref",
			  Ref("demo:hash"),
			  3),
		       2));
			
  $txt .= ShowLine(Op2("=",
		       Op("hash-ref",
			  Ref("demo:hash"),
			  8),
		       Ref("undefined")));
			
  $txt .= ShowLine(Op2("=",
		       Op("hash-ref",
			  Ref("demo:hash"),
			  15),
		       Ref("undefined")));
			
  $txt .= ShowLine(Op2("=",
		       Op("hash-ref",
			  Op("hash-add",
			     Ref("demo:hash"),
			     15,
			     33),
			  15),
		       33));
			
  $txt .= ShowLine(Op2("=",
		       Op("hash-ref",
			  Ref("demo:hash"),
			  15),
		       Ref("undefined")));

  $txt .= ShowLine(Op2("define",
		       "make-hash",
		       Proc("x",
			    Op("if",
			       Op2("list=",Ref("x"),Op("vector")),
			       Ref("hash-null"),
			       Op("hash-add",
				  Op("make-hash", Op1("tail", Ref("x"))),
				  Op1("first",Op1("head",Ref("x"))),
				  Op1("second",Op1("head",Ref("x"))))))));

  $txt .= ShowLine(Op2("=",
		       Op2("hash-ref",
			   Op1("make-hash",
			       Op("vector",
				  Op2("pair", 3, 10),
				  Op2("pair", 2, 20),
				  Op2("pair", 1, 30))),
			   3),
		       10));
  $txt .= ShowLine(Op2("=",
		       Op2("hash-ref",
			   Op1("make-hash",
			       Op("vector",
				  Op2("pair", 3, 10),
				  Op2("pair", 2, 20),
				  Op2("pair", 1, 30))),
			   1),
		       30));

  return $txt;
};


ShowLesson(ShowHashLesson());

