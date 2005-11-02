#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowAdditionLesson {
  my $txt = "";
  $txt .= "# MATH introduce addition\n";
  $txt .= ShowLine(Op("intro","+"));
  for (my $i=0; $i<10; $i++)
    {
      my $r = irand(5);
      my $r2 = irand(5);
      $txt .= ShowLine(TailOp2("=",
			   ShowUnary($r+$r2),
			   Op2("+",
			       ShowUnary($r),
			       ShowUnary($r2))));
    }
  return $txt;
};


ShowLesson(ShowAdditionLesson());

