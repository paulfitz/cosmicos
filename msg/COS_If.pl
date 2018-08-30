#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowIfLesson {

  my $txt = "";
  $txt .= "# MATH show mechanisms for branching\n";

  if (0) {
      $txt .= "# there are some arcane definitions which can be safely ignored\n";
      
      $txt .= "(define select-second / ? x / ? y / y);\n";
      $txt .= "(define select-first / ? x / ? y / x);\n";
      $txt .= "# the following will work if true is 1 and false is 0\n";
      $txt .= "(define testif / ? x / assign 0 (select-second) / assign 1 (select-first) / ((((x)))));\n";
      $txt .= "
  (select-second 5 10);
  (select-first 5 10);
  (testif 0);
  (testif 1);
  (testif 1 1 0);
  (define 0 42);
  (0);
  ((0));
  ";
  }

  $txt .= ShowLine(Op("intro","if"));

#  $txt .= "#CHECK111\n(= 2 1);\n(if (= 2 1) 25 20);\n";

  for (my $i=0; $i<8; $i++)
    {
      my $r1 = irand(2);
      my $r2 = 20+irand(10);
      my $r3 = 20+irand(10);
      my $cmp = ShowTrue();
      my $out = "";
      if ($r1)
	{
	  $cmp = ShowTrueComparisonBin();
	}
      else
	{
	  $cmp = ShowFalseComparisonBin();
	}
      if ($r1)
	{
	  $out .= Num($r2);
	}
      else
	{
	  $out = Num($r3);
	}
      $txt .= ShowLine(TailOp2("=",
			       $out,
			       Op("if",
				  $cmp,
				  Num($r2),
				  Num($r3))));
    }

  $txt .= "(define max | ? x | ? y | if (> \$x \$y) \$x \$y);\n";
  $txt .= "(define min | ? x | ? y | if (< \$x \$y) \$x \$y);\n";
  for (my $r1=0; $r1<3; $r1++) {
      for (my $r2=0; $r2<3; $r2++) {
	  my $rmax = ($r1>$r2)?$r1:$r2;
	  my $rmin = ($r1<$r2)?$r1:$r2;
	  $txt .= "(= $rmax | max $r1 $r2);\n";
	  $txt .= "(= $rmin | min $r1 $r2);\n";
      }  
  }
  $txt .= "# 'if' does not evaluate branch-not-taken, TODO show this.\n";
  $txt .= "(define factorial | ? x | if (< \$x 1) 1 | * \$x | factorial | - \$x 1);\n";
  my $v = 1;
  for (my $i=1; $i<=5; $i++) {
      $v = $v*$i;
      $txt .= "(= $v | factorial $i);\n";
  }

  return $txt;
};


ShowLesson(ShowIfLesson());

