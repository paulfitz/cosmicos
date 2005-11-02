#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowOrLogicLesson {
  my $txt = "";
  $txt .= "# MATH introduce the OR logical operator\n";
  
  $txt .= "(define or (? x / ? y / if (x) (true) (if (y) (true) (false))));\n";
  $txt .= ShowLine(Op("intro","or"));
  for (my $i=0; $i<10; $i++)
    {
      $txt .= ShowLine(Op2("or",ShowTrueComparison(),ShowTrueComparison()));
    }

  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("or",ShowTrueComparison(),ShowFalseComparison()));
    }

  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op2("or",ShowFalseComparison(),ShowTrueComparison()));
    }

  for (my $i=0; $i<5; $i++)
    {
      $txt .= ShowLine(Op1("not",
			   Op2("or",
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
      my $c = Op2("or",$c1,$c2);
      
      if (!(($t1==1)||($t2==1)))
	{
	  $c = Op1("not",$c);
	}
      $txt .= ShowLine($c);
    }

  $txt .= "(define >= (? x / ? y / or (> (x) (y)) (= (x) (y))));\n";
  $txt .= "(define <= (? x / ? y / or (< (x) (y)) (= (x) (y))));\n";
  for (my $i=0; $i<3; $i++) {
      for (my $j=0; $j<3; $j++) {
	  $txt .= "(" . (($i>=$j)?"":"not / ") . ">= $i $j);\n";
	  $txt .= "(" . (($i<=$j)?"":"not / ") . "<= $i $j);\n";
      }
  }


  return $txt;
}


ShowLesson(ShowOrLogicLesson());

