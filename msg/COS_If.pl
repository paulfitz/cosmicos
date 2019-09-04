#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowIfLesson {

  my $txt = "";

  $txt .= ShowLine(Op("intro","if"));

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

  $txt .= "~ We can now define more interesting functions.  Here's the maximum of two integers:\n";
  $txt .= "(define max | ? x | ? y | if (> \$x \$y) \$x \$y);\n";
  for (my $r1=0; $r1<3; $r1++) {
      for (my $r2=0; $r2<3; $r2++) {
	  my $rmax = ($r1>$r2)?$r1:$r2;
	  $txt .= "(= $rmax | max $r1 $r2);\n";
      }  
  }
  $txt .= "~ Now the minimum of two integers:\n";
  $txt .= "(define min | ? x | ? y | if (< \$x \$y) \$x \$y);\n";
  for (my $r1=0; $r1<3; $r1++) {
      for (my $r2=0; $r2<3; $r2++) {
	  my $rmin = ($r1<$r2)?$r1:$r2;
	  $txt .= "(= $rmin | min $r1 $r2);\n";
      }  
  }
  $txt .= "~ Why should human CS students be the only ones the factorial example is inflicted on...\n";
  $txt .= "(define factorial | ? x | if (< \$x 1) 1 | * \$x | factorial | - \$x 1);\n";
  my $v = 1;
  for (my $i=1; $i<=5; $i++) {
      $v = $v*$i;
      $txt .= "(= $v | factorial $i);\n";
  }

  return $txt;
};


ShowLesson(ShowIfLesson());

