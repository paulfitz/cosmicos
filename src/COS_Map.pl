#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowMapLesson {
  my $txt = "";
  
  $txt .= "# MATH show map function for applying a function across the elements of a list\n";

  $txt .= ShowLine(Op2("define",
		       "map",
		       ProcMultiple(["p", "lst"],
				    Op("if",
				       Op2(">",
					   Op1("list-length", Ref("lst")),
					   0),
				       Op2("prepend",
					   Op("p",Op1("head",Ref("lst"))),
					   Op("map",
					      Ref("p"),
					      Op1("tail",Ref("lst")))),
				       ShowList()))));

  for (my $i=0; $i<4; $i++)
    {
      my @list = prand(20,$i+3);
      my @out = ();
      foreach my $n (@list)
	{
	  push(@out,2*$n);
	}
      $txt .= ShowLine(Op2("list=",
			   Op("map",
			      Proc("x",
				   Op2("*",Ref("x"),2)),
			      ShowList(@list)),
			   ShowList(@out)));
    }
     
  for (my $i=0; $i<4; $i++)
    {
      my @list = prand(20,$i+3);
      my @out = ();
      foreach my $n (@list)
	{
	  push(@out,42);
	}
      $txt .= ShowLine(Op2("list=",
			   Op("map",
			      Proc("x",
				   42),
			      ShowList(@list)),
			   ShowList(@out)));
    }

  $txt .= ShowLine(Op2("define",
		       "crunch",
		       ProcMultiple(["p", "lst"],
				    Op("if",
				       Op2(">=",
					   Op1("list-length", Ref("lst")),
					   2),
				       Apply("p",
					     Op1("head",Ref("lst")),
					     Op("crunch",
						Ref("p"),
						Op1("tail",Ref("lst")))),
				       Op("if",
					  Op2("=",
					      Op1("list-length", Ref("lst")),
					      1),
					  Op1("head",Ref("lst")),
					  Ref("undefined"))))));
  for (my $i=0; $i<4; $i++)
    {
      my @list = prand(20,$i+3);
      my @out = ();
      my $sum = 0;
      foreach my $n (@list)
	{
	  $sum += $n;
	}
      
      $txt .= ShowLine(Op2("=",
			   Op("crunch",
			      Ref("+"),
			      ShowList(@list)),
			   $sum));
    }
  

  return $txt;
};


ShowLesson(ShowMapLesson());

