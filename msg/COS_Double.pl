#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowDoubleLesson {
  my $txt = "";
  $txt .= "# MATH introduce doubling as a special case of multiplication\n";
  $txt .= "# as prelude to binary representation\n";
  $txt .= ShowLine(Op("intro",":"));
  for (my $i=0; $i<=4; $i++)
    {
      $txt .= ShowLine(Op2("=",Op1(":",ShowUnary($i)),ShowUnary($i*2)));
    }  
  for (my $i=0; $i<=4; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowUnary($i*2),Op1(":",ShowUnary($i))));
    }  
  for (my $i=0; $i<=4; $i++)
    {
      $txt .= ShowLine(Op2("=",
			   Op2("*",ShowUnary($i),ShowUnary(2)),
			   Op1(":",ShowUnary($i))));
    }  
  for (my $i=0; $i<=4; $i++)
    {
      $txt .= ShowLine(Op2("=",
			   BareOp1(":",ShowUnary($i)),
			   Op1(":",ShowUnary($i))));
    }  
  return $txt;
};


ShowLesson(ShowDoubleLesson());

