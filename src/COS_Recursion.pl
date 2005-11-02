#!/usr/bin/perl -w
use strict;

use cosmic;

sub Factorial {
  my $r = 1;
  my $x = shift;
  if ($x>0)
    {
      $r = $x*Factorial($x-1);
    }
  return $r;
};


sub ShowRecursionLesson {
  my $txt = "";
  $txt .= "# MATH show an example of recursive evaluation\n";
  $txt .= "# skipping over a lot of definitions and desugarings\n";
  $txt .= ShowLine(Op2("define",
		       Lit("easy-factorial"),
		       Proc(Lit("f"),
			    Proc(Lit("x"),
				 (Op("if",
				     Op2(">",Ref("x"),Num(0)),
				     TailOp2("*",
					 Ref("x"),
					 Apply(Lit("f"),
					       Ref("f"),
					       Op2("-",Ref("x"),Num(1)))),
				     1))))));
  $txt .= ShowLine(Op2("define",
		       Lit("factorial"),
		       Proc(Lit("x"),
			    (Op("if",
				Op2(">",Ref("x"),Num(0)),
				TailOp2("*",
					Ref("x"),
					TailOp1(Lit("factorial"),
						Op2("-",Ref("x"),Num(1)))),
				1)))));
  for (my $i=0; $i<=5; $i++)
    {
      $txt .= ShowLine(Op2("=",
			   Apply("easy-factorial",
				 Ref("easy-factorial"),
				 Num($i)),
			   Factorial($i)));
    }
  for (my $i=0; $i<=5; $i++)
    {
      $txt .= ShowLine(Op2("=",
			   Apply("factorial",
				 Num($i)),
			   Factorial($i)));
    }

# this unary function is broken - see fritz code for a good one
#  $txt .= "# show a definition for the unary function used early on\n";
#  $txt .= ShowLine(Op2("define",
#		       "unary",
#		       Proc("x",
#			    Op("if",
#			       Op2("=",Ref("x"),0),
#			       0,
#			       Op2("+",Ref("unary"),1)))));

  return $txt;
};


ShowLesson(ShowRecursionLesson());

