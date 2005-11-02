#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowMultiplicationLesson {
  my $txt = "";
  $txt .= "# MATH introduce multiplication\n";
  $txt .= ShowLine(Op("intro","*"));
  for (my $i=0; $i<=3; $i++)
    {
      for (my $j=0; $j<=3; $j++)
	{
	  $txt .= ShowLine(TailOp2("=",
			       ShowUnary($i*$j),
			       Op2("*",
				   ShowUnary($i),
				   ShowUnary($j))));
	}
    }
  for (my $i=0; $i<10; $i++)
    {
      my $r = irand(4);
      my $r2 = irand(4);
      $txt .= ShowLine(TailOp2("=",
			   ShowUnary($r*$r2),
			   Op2("*",
			       ShowUnary($r),
			       ShowUnary($r2))));
    }
  return $txt;
};


ShowLesson(ShowMultiplicationLesson());

