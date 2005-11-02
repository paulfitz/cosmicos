#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowQuantifierLesson {
  my $txt = "";
  $txt .= "# MATH introduce universal quantifier\n";
  $txt .= "# really need to link with sets for true correctness\n";
  $txt .= "# and the examples here are REALLY sparse, need much more\n";
  $txt .= ShowLine(Op("intro","forall"));
  for (my $i=5; $i>=0; $i--)
    {
      $txt .= ShowLine(Op2("<",
			   Num($i),
			   Op2("+",Num($i),Num(1))));
    }
  $txt .= ShowLine(Op("forall",
		      Proc(Lit("x"),
			   Op2("<",
			       Ref("x"),
			       Op2("+",Ref("x"),Num(1))))));
  for (my $i=5; $i>=0; $i--)
    {
      my $txt0 = Op2("<",
		     Num($i),
		     Op2("*",Num($i),Num(2)));
      if (!($i<$i*2))
	{
	  $txt0 = Op1("not",$txt0);
	}
      $txt .= ShowLine($txt0);
    }
  $txt .= ShowLine(Op1("not",
		       Op("forall",
			  Proc(Lit("x"),
			       Op2("<",
				   Ref("x"),
				   Op2("*",Ref("x"),Num(2)))))));
  $txt .= "# MATH introduce existential quantifier\n";
  $txt .= "# really need to link with sets for true correctness\n";
  $txt .= "# and the examples here are REALLY sparse, need much more\n";
  for (my $i=5; $i>=0; $i--)
    {
      my $txt0 = Op2("=",
		     Num($i),
		     Op2("*",Num(2),Num(2)));
      if (!($i==2*2))
	{
	  $txt0 = Op1("not",$txt0);
	}
      $txt .= ShowLine($txt0);
    }
  $txt .= ShowLine(Op("intro","exists"));
  $txt .= ShowLine(Op("exists",
		      Proc(Lit("x"),
			   Op2("=",
			       Ref("x"),
			       Op2("*",Num(2),Num(2))))));

  for (my $i=5; $i>=0; $i--)
    {
      my $txt0 = Op2("=",
		     Num($i),
		     Op2("+",Num($i),Num(2)));
      if (!($i==$i+1))
	{
	  $txt0 = Op1("not",$txt0);
	}
      $txt .= ShowLine($txt0);
    }
  $txt .= ShowLine(Op("not",
		      Op("exists",
			 Proc(Lit("x"),
			      Op2("=",
				  Ref("x"),
				  Op2("+",Ref("x"),Num(2)))))));

  return $txt;
};


ShowLesson(ShowQuantifierLesson());

