#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowTrueFalseLesson {
  my $txt = "";
  $txt .= "# MATH use equality for truth values\n";

  $txt .= "# Not quite committing to a *type* for truth values in the message, side-stepping that issue until we really need to decide it.\n";
  $txt .= ShowLine(Op("define","true",Op2("=",0,0)));
  $txt .= ShowLine(Op("define","false",Op2("=",0,1)));
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowTrue(),ShowTrueComparisonBin()));
    }
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowTrueComparisonBin(),ShowTrue()));
    }
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowFalse(),ShowFalseComparisonBin()));
    }
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowFalseComparisonBin(),ShowFalse()));
    }
  $txt .= ShowLine(Op2("=",ShowTrue(),ShowTrue()));
  $txt .= ShowLine(Op2("=",ShowFalse(),ShowFalse()));
  $txt .= ShowLine(Op1("not",Op2("=",ShowTrue(),ShowFalse())));
  $txt .= ShowLine(Op1("not",Op2("=",ShowFalse(),ShowTrue())));

  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowTrueComparisonBin(),ShowTrueComparisonBin()));
    }
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowFalseComparisonBin(),ShowFalseComparisonBin()));
    }
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op1("not",
			   Op2("=",
			       ShowFalseComparisonBin(),
			       ShowTrueComparisonBin())));
    }
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op1("not",
			   Op2("=",
			       ShowTrueComparisonBin(),
			       ShowFalseComparisonBin())));
    }
#  $txt .= ShowLine(Op("intro","true"));
#  $txt .= ShowLine(Op("intro","false"));

  return $txt;
};


ShowLesson(ShowTrueFalseLesson());

