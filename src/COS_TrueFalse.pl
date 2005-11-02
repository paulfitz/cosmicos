#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowTrueFalseLesson {
  my $txt = "";
  $txt .= "# MATH use equality for truth values\n";
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowTrueComparison(),ShowTrueComparison()));
    }
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowFalseComparison(),ShowFalseComparison()));
    }
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op1("not",
			   Op2("=",
			       ShowFalseComparison(),
			       ShowTrueComparison())));
    }
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op1("not",
			   Op2("=",
			       ShowTrueComparison(),
			       ShowFalseComparison())));
    }
#  $txt .= ShowLine(Op("intro","true"));
#  $txt .= ShowLine(Op("intro","false"));
  print "# This could all be simplified or removed\n";
  print "# once the handling of true/false stabilizes\n";
  $txt .= ShowLine(Op("define","true",Num(1)));
  $txt .= ShowLine(Op("define","false",Num(0)));
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowTrue(),ShowTrueComparison()));
    }
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowTrueComparison(),ShowTrue()));
    }
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowFalse(),ShowFalseComparison()));
    }
  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("=",ShowFalseComparison(),ShowFalse()));
    }
  $txt .= ShowLine(Op2("=",ShowTrue(),ShowTrue()));
  $txt .= ShowLine(Op2("=",ShowFalse(),ShowFalse()));
  $txt .= ShowLine(Op1("not",Op2("=",ShowTrue(),ShowFalse())));
  $txt .= ShowLine(Op1("not",Op2("=",ShowFalse(),ShowTrue())));

  return $txt;
};


ShowLesson(ShowTrueFalseLesson());

