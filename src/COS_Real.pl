#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowRealLesson {
  my $txt = "";
  $txt .= "# MATH introduce reals\n";
  $txt .= ShowLine(Op("intro","."));
  for (my $i=0.0; $i<10.0; $i++)
    {
      my $r = irand(5);
      my $r2 = irand(5);
      $txt .= ShowLine(TailOp2("=",
			   ShowReal($r+$r2),
			   Op2("=",
			       ShowReal($r),
			       ShowReal($r2))));
    }
  return $txt;
};


ShowLesson(ShowAdditionLesson());