#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowSetLesson {
  my $txt = "";
  $txt .= "# MATH introduce sets and set membership\n";

  $txt .= ShowLine(Op1("intro","element"));
  $txt .= ShowLine(Op2("define",
		       "element",
		       Proc("x",
			    Proc("lst",
				 Op1("not",
				     Op2("=",
					 Op("list-find-helper",
					    Ref("lst"),
					    Ref("x"),
					    "1"),
					 "\$undefined"))))));

  for (my $i=0; $i<5; $i++)
    {
      my %hset;
      my @set;
      for (my $j=0; $j<6; $j++)
	{
	    my $x = irand(10);
	    if (!exists($hset{$x})) {
		$hset{$x} = 1;
		push(@set,$x);
	    }
	}
      for (my $j=0; $j<3; $j++)
	{
	  my $mem = $set[irand($#set+1)];
	  $txt .= ShowLine(Op("element",
			      Num($mem),
			      ShowList(@set)));
	}
    }
  for (my $i=0; $i<5; $i++)
    {
      my %hset;
      my @set;
      for (my $j=0; $j<6; $j++)
	{
	    my $x = irand(10);
	    if (!exists($hset{$x})) {
		$hset{$x} = 1;
		push(@set,$x);
	    }
	}
      (my $mem, @set) = @set;
      $txt .= ShowLine(Op1("not",
			   Op("element",
			      Num($mem),
			      ShowList(@set))));
    }

  $txt .= "# rules for set equality\n";

  $txt .= ShowLine(Op2("define",
		       "set-subset",
		       Proc("x",
			    Proc("y",
				 Op("if",
				    Op2(">", Op1("list-length",Ref("x")), 0),
				    Op2("and",
					Op2("element",
					    Op1("head",Ref("x")),
					    Ref("y")),
					Op2("set-subset",
					    Op1("tail",Ref("x")),
					    Ref("y"))),
				    Op("true"))))));

  $txt .= ShowLine(Op2("define",
		       "set=",
		       Proc("x",
			    Proc("y",
				 Op2("and",
				     Op2("set-subset", Ref("x"), Ref("y")),
				     Op2("set-subset", Ref("y"), Ref("x")))))));
				 

  $txt .= ShowLine(Op2("set=",
		      ShowList("1", "5", "9"),
		      ShowList("5", "1", "9")));
  $txt .= ShowLine(Op2("set=",
		       ShowList("1", "5", "9"),
		       ShowList("9", "1", "5")));
  $txt .= ShowLine(Op1("not",
		       Op2("set=",
			   ShowList("1", "5", "9"),
			   ShowList("1", "5"))));

  $txt .= "# let's go leave ourselves wide open to Russell's paradox\n";
  $txt .= "# ... by using characteristic functions\n";
  $txt .= "# ... since it doesn't really matter for communication purposes\n";
  $txt .= "# ... and so far this is just used/tested with sets of integers really\n";
  $txt .= ShowLine(Op2("element",
		       Num(5),
		       Op("all",
			  Proc(Lit("x"),
			       Op("=",
				  Op2("+",
				      Ref("x"),
				      Num(10)),
				  Num(15))))));
  $txt .= ShowLine(Op2("element",
		       Num(3),
		       Op("all",
			  Proc(Lit("x"),
			       Op("=",
				  Op2("*",
				      Ref("x"),
				      Num(3)),
				  Op2("+",
				      Ref("x"),
				      Num(6)))))));


  $txt .= ShowLine(Op("define",
		      Lit("empty-set"),
		      ShowList()));

  $txt .= ShowLine(Op2("element",
		       Num(0),
		       Ref("natural-set")));
  $txt .= ShowLine(Op("forall",
		      Proc(Lit("x"),
			   Op2("=>",
			       Op2("element",
				   Ref("x"),
				   Ref("natural-set")),
			       Op2("element",
				   Op2("+", Ref("x"), Num(1)),
				   Ref("natural-set"))))));

  for (my $i=1; $i<10; $i++)
    {
      $txt .= ShowLine(Op2("element",
			   Num($i),
			   Ref("natural-set")));      
    }

#  $txt .= "# " . ShowLine(Op1("not",
#		       Op2("element",
#			   ShowTrue(),
#			   Ref("natural-set"))));

#  $txt .= "# " . ShowLine(Op1("not",
#		       Op2("element",
#			   ShowFalse(),
#			   Ref("natural-set"))));


  $txt .= ShowLine(Op("define",
		      Lit("boolean-set"),
		      ShowList(ShowTrue(), ShowFalse())));

  $txt .= ShowLine(Op2("element",
		       Lit(ShowTrue()),
		       Ref("boolean-set")));
  
  $txt .= ShowLine(Op2("element",
		       Lit(ShowFalse()),
		       Ref("boolean-set")));

  $txt .= "# actually, to simplify semantics elsewhere, true and false\n";
  $txt .= "# are now just 0 and 1 so they are not distinct from ints\n";

  
#  $txt .= "# " . ShowLine(Op1("not",
#		       Op2("element",
#			   "0",
#			   Ref("boolean-set"))));
  

  $txt .= ShowLine(Op("define",
		      Lit("even-natural-set"),
		      Op1("all",
			  Proc(Lit("x"),
			       Op1("exists",
				   Proc(Lit("y"),
					Op2("and",
					    Op2("element", 
						Ref("y"), 
						Ref("natural-set")),
					    Op2("=",
						Op2("*",2,Ref("y")),
						Ref("x")))))))));

  for (my $i=0; $i<=6; $i++)
    {
      my $txt0 = Op2("element",
		  Num($i),
		  Ref("even-natural-set"));
      if (($i%2)!=0)
	{
	  $txt0 = Op1("not",$txt0);
	}
      $txt .= ShowLine(Op2("element",
			   Num($i),
			   Ref("natural-set")));      
      $txt .= ShowLine($txt0);
    }

  
  return $txt;
};


ShowLesson(ShowSetLesson());

