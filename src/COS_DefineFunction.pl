#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowDefineFunctionLesson {
  my $txt = "";
  $txt .= "# MATH demonstrate existence of memory\n";
  $txt .= "(define forty-something 42);\n";
  $txt .= "(= 42 (forty-something));\n";
#  $txt .= "(assign x (forty-something) / define forty-something (+ 1 / x));\n";
#  $txt .= "(forty-something);\n";
#  $txt .= "(= 43 (forty-something));\n";
  
  $txt .= "# now introduce a function\n";
  for (my $i=0; $i<4; $i++)
    {
      my $r = irand(10);
      $txt .= "(assign square (? x / * (x) (x)) / = " . ($r*$r) . " (square $r));\n";
#      $txt .= ShowLine(TailOp2("=",
#			   Num($r*$r),
#			   Apply(Proc(Lit("square"),
#				      Apply(Lit("square"),
#					    Num($r))),
#				 Proc(Lit("x"),
#				      Op2("*", Ref("x"), Ref("x"))))));

    }
  $txt .= "# show that functions can be remembered across statements\n";
  $txt .= ShowLine(Op2("define",
		       Lit("square"),
		       Proc(Lit("x"),
			    Op2("*", Ref("x"), Ref("x")))));
  for (my $i=0; $i<4; $i++)
    {
      my $r = irand(10);
      $txt .= ShowLine(Op2("=",
			   Apply(Lit("square"),
				 Num($r)),
			   Num($r*$r)));
    }
  $txt .= ShowLine(Op2("define",
		       Lit("plusone"),
		       Proc(Lit("x"),
			    Op2("+", Ref("x"), Lit("1")))));
  for (my $i=0; $i<4; $i++)
    {
      my $r = irand(10);
      $txt .= ShowLine(Op2("=",
			   Apply(Lit("plusone"),
				 Num($r)),
			   Num($r+1)));
    }

  return $txt;
};


ShowLesson(ShowDefineFunctionLesson());

