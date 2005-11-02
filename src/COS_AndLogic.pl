#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowAndLogicLesson {
  my $txt = "";
  $txt .= "# MATH introduce the AND logical operator\n";
  
  $txt .= ShowLine(Op("intro","and"));

  $txt .= "(define and (? x / ? y / if (x) (if (y) (true) (false)) (false)));\n";

  for (my $i=0; $i<10; $i++)
    {
      $txt .= ShowLine(Op2("and",ShowTrueComparison(),ShowTrueComparison()));
    }

  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op1("not",
			   Op2("and",
			       ShowTrueComparison(),
			       ShowFalseComparison())));
    }

  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op1("not",
			   Op2("and",
			       ShowFalseComparison(),
			       ShowTrueComparison())));
    }

  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op1("not",
			   Op2("and",
			       ShowFalseComparison(),
			       ShowFalseComparison())));
    }

  for (my $i=0; $i<10; $i++)
    {
      my $t1 = irand(2);
      my $t2 = irand(2);
      my $c1 = "";
      my $c2 = "";
      if ($t1==1)
	{
	  $c1 = ShowTrueComparison();
	}
      else
	{
	  $c1 = ShowFalseComparison();
	}
      if ($t2==1)
	{
	  $c2 = ShowTrueComparison();
	}
      else
	{
	  $c2 = ShowFalseComparison();
	}
      my $c = Op2("and",$c1,$c2);
      
      if (!(($t1==1)&&($t2==1)))
	{
	  $c = Op1("not",$c);
	}
      $txt .= ShowLine($c);
    }

  return $txt;
}


ShowLesson(ShowAndLogicLesson());

