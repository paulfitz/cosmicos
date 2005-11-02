#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowBinaryLesson {
  my $txt = "";
  $txt .= "# MATH introduce a simple form of binary notation\n";
  $txt .= "# After this lesson, in the higher-level version of the message,\n";
  $txt .= "# will expand decimal to stand for the binary notation given.\n";
  $txt .= "# It wouldn't be hard to accompany this lesson with a more\n";
  $txt .= "# formal definition once functions are introduced (below)\n";
  $txt .= "# so maybe the transition to binary should be delayed?\n";
  my $v = 1;
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowBinaryVerbose($v),ShowUnary($v)));
      $v = $v*2;
    }
  for (my $i=0; $i<16; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowBinaryVerbose($i),ShowUnary($i)));
    }
  for (my $i=0; $i<16; $i++)
    {
      my $j = irand(16);
      $txt .= ShowLine(Op2("=",ShowBinaryVerbose($j),ShowUnary($j)));
    }
  for (my $i=0; $i<8; $i++)
    {
      my $r = irand(8);
      my $r2 = irand(8);
      $txt .= ShowLine(TailOp2("=",
			       ShowUnary($r+$r2),
			       Op2("+",
				   ShowUnary($r),
				   ShowUnary($r2))));
      $txt .= ShowLine(TailOp2("=",
			       ShowBinaryVerbose($r+$r2),
			       Op2("+",
				   ShowBinaryVerbose($r),
				   ShowBinaryVerbose($r2))));
    }
  for (my $i=0; $i<8; $i++)
    {
      my $r = irand(4)+1;
      my $r2 = irand(4)+1;
      $txt .= ShowLine(TailOp2("=",
			       ShowUnary($r*$r2),
			       Op2("*",
				   ShowUnary($r),
				   ShowUnary($r2))));
      $txt .= ShowLine(TailOp2("=",
			       ShowBinaryVerbose($r*$r2),
			       Op2("*",
				   ShowBinaryVerbose($r),
				   ShowBinaryVerbose($r2))));
    }
  return $txt;
};


ShowLesson(ShowBinaryLesson());

