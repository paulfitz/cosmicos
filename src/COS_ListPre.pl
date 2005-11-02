#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowListLesson {
  my $txt = "";
  $txt .= "# MATH illustrate lists and some list operators\n";
  $txt .= "# to make list describable as a function, need to preceed lists\n";
  $txt .= "# ... with an argument count\n";
  $txt .= "# Lists keep an explicit record of their length\n";
  $txt .= "# this is to avoid the need for using a special 'nil' symbol\n";
  $txt .= "# ... which cannot itself be placed in the list.\n";

  $txt .= "# pending: should introduce number? check function\n";

  $txt .= ShowLine(Op2("define",
		       "list-helper",
		       Proc("n",
			    Proc("ret",
				 Op("if",
				    Op2(">", Ref("n"), 1),
				    Proc("x",
					 Apply("list-helper",
					       Op2("-", Ref("n"), 1),
					       Proc("y",
						    Proc("z",
							 Apply("ret",
							       Op2("+", 1, Ref("y")),
							       Op2("cons",
								   Ref("x"),
								   Ref("z"))))))),
				    Proc("x",
					 Apply("ret",
					       1,
					       Ref("x"))))))));

  $txt .= ShowLine(Op2("define",
		       "list",
		       Proc("n",
			    Op("if",
			       Op2("=", Ref("n"), 0),
			       Op2("cons", 0, 0),
			       Op("list-helper",
				  Ref("n"),
				  Proc("y",
				       Proc("z",
					    Op2("cons", Ref("y"), Ref("z")))))))));

  $txt .= ShowLine(Op2("define",
		       "head",
		       Proc("lst",
			    Op("if",
			       Op2("=", Op1("car", Ref("lst")), "0"),
			       Ref("undefined"),
			       Op("if",
				  Op2("=", Op1("car", Ref("lst")), "1"),
				  Op1("cdr", Ref("lst")),
				  Op1("car", Op1("cdr",Ref("lst"))))))));
  
  $txt .= ShowLine(Op2("define",
		       "tail",
		       Proc("lst",
			    Op("if",
			       Op2("=", Op1("car", Ref("lst")), "0"),
			       Ref("undefined"),
			       Op("if",
				  Op2("=", Op1("car", Ref("lst")), "1"),
				  Op2("cons", 0, 0),
				  Op2("cons",
				      Op2("-", Op1("car", Ref("lst")), "1"),
				      Op1("cdr",Op1("cdr",Ref("lst")))))))));

  $txt .= ShowLine(Op2("define",
		       "list-length",
		       Proc("lst",
			    Op1("car", Ref("lst")))));

  $txt .= ShowLine(Op2("define",
		       "list-ref",
		       Proc("lst",
			    Proc("n",
				 Op("if",
				    Op2("=",
					Op1("list-ref",Ref("lst")),
					0),
				    Ref("undefined"),
				    Op("if",
				       Op2("=",Ref("n"),0),
				       Op1("head", Ref("lst")),
				       Op2("list-ref",
					   Op1("tail", Ref("lst")),
					   Op2("-", Ref("n"), 1))))))));
			
  $txt .= ShowLine(Op2("define",
		       "prepend",
		       Proc("x",
			    Proc("lst",
				 Op("if",
				    Op2("=",Op1("list-length", Ref("lst")),0),
				    Op2("cons", 1, Ref("x")),
				    Op2("cons", 
					Op2("+", 
					    Op1("list-length", Ref("lst")),
					    1),
					Op2("cons",
					    Ref("x"),
					    Op1("cdr",Ref("lst")))))))));

  $txt .= ShowLine(Op2("define",
		       "equal",
		       Proc("x",
			    Proc("y",
				 Op("if",
				    Op2("=",
					Op("number?",Ref("x")),
					Op("number?",Ref("y"))),
				    Op("if",
				       Op("number?",Ref("x")),
				       Op2("=",Ref("x"),Ref("y")),
				       Op2("list=",Ref("x"),Ref("y"))),
				    Ref("false"))))));
  $txt .= ShowLine(Op2("define",
		       "list=",
		       Proc("x",
			    Proc("y",
				 Op("if",
				    Op2("=", 
					Op1("list-length", Ref("x")),
					Op1("list-length", Ref("y"))),
				    Op("if",
				       Op2(">", Op1("list-length", Ref("x")), 0),
				       Op2("and",
					   Op2("equal",
					       Op1("head",Ref("x")),
					       Op1("head",Ref("y"))),
					   Op2("list=",
					       Op1("tail",Ref("x")),
					       Op1("tail",Ref("y")))),
				       Ref("true")),
				    Ref("false"))))));


  my @examples = prand(10,5);
  for (my $i=0; $i<=$#examples; $i++)
    {
      my $r = $examples[$i];
      $txt .= ShowLine(Op2("=",
			   Op1("list-length",
			       ShowListVerbose(prand(10,$r))),
			   $r));
    }

  for (my $i=0; $i<10; $i++)
    {
      my $len = irand(10)+1;
      my @lst = ();
      for (my $j=0; $j<$len; $j++)
	{
	  push(@lst,irand(20));
	}
      my ($head, @tail) = @lst;
      $txt .= ShowLine(Op2("=",
			   Op1("head",
			       ShowListVerbose(@lst)),
			   $head));
      $txt .= ShowLine(Op2("list=",
			   Op1("tail",
			       ShowListVerbose(@lst)),
			   ShowListVerbose(@tail)));

    }
  for (my $i=0; $i<10; $i++)
    {
      my $len = irand(10)+1;
      my @lst = ();
      for (my $j=0; $j<$len; $j++)
	{
	  push(@lst,irand(20));
	}
      my $idx = irand($len);
      my $val = $lst[$idx];
      $txt .= ShowLine(Op2("=",
			   Op2("list-ref",
			       ShowListVerbose(@lst),
			       $idx),
			   $val));
    }
  for (my $i=0; $i<5; $i++)
    {
      my $len = $i;
      my @lst = ();
      my $cmp = "list=";
      for (my $j=0; $j<$len; $j++)
	{
	  push(@lst,irand(20));
	}
      my $idx = irand($len);
      my $val = $lst[$idx];
      $txt .= ShowLine(Op2($cmp,
			   ShowListVerbose(@lst),
			   ShowListVerbose(@lst)));
    }
  $txt .= "# this next batch of examples are a bit misleading, should streamline\n";
  for (my $i=0; $i<5; $i++)
    {
      my $len = $i;
      my @lst = ();
      my $cmp = "list=";
      for (my $j=0; $j<$len; $j++)
	{
	  push(@lst,irand(20));
	}
      my $idx = irand($len);
      my $val = $lst[$idx];
      $txt .= ShowLine(Op1("not",
			   Op2($cmp,
			       ShowListVerbose(@lst),
			       ShowListVerbose((irand(10), @lst)))));
      $txt .= ShowLine(Op1("not",
			   Op2($cmp,
			       ShowListVerbose(@lst),
			       ShowListVerbose((@lst, irand(10))))));
    }

  $txt .= "# some helpful functions\n";

  for (my $i=0; $i<8; $i++)
    {
      my $len = $i;
      my @lst = ();
      my $cmp = "=";
      for (my $j=0; $j<$len; $j++)
	{
	  push(@lst,irand(20));
	}
      my $val = irand(20);
      $txt .= ShowLine(Op2("list=",
			   Op("prepend",
			      $val,
			      ShowListVerbose(@lst)),
			   ShowListVerbose($val, @lst)));
    }

#  $txt .= ShowLine(Op2("define",
#		       "list-length",
#		       Proc("x",
#			    Op("if",
#			       Op2("=",
#				   Ref("x"),
#				   ShowListVerbose()),
#			       0,
#			       Op2("+",
#				   1,
#				   Op1("list-length",
#				       Op1("tail",Ref("x"))))))));

  $txt .= ShowLine(Op2("define",
		       "pair",
		       Proc("x",
			    Proc("y",
				 ShowListVerbose(Ref("x"), Ref("y"))))));

  $txt .= ShowLine(Op2("define",
		       "first",
		       Proc("lst",
			    Op1("head",Ref("lst")))));

  $txt .= ShowLine(Op2("define",
		       "second",
		       Proc("lst",
			    Op1("head",Op1("tail",Ref("lst"))))));

  @examples = prand(10,3);
  my @examples2 = prand(10,$#examples+1);
  for (my $i=0; $i<=$#examples; $i++)
    {
      my $r = $examples[$i];
      my $r2 = $examples2[$i];
      $txt .= ShowLine(Op2("list=",
			   Op2("pair", $r, $r2),
			   ShowListVerbose($r, $r2)));
      $txt .= ShowLine(Op2("=",
			   Op1("first",Op2("pair", $r, $r2)),
			   $r));
      $txt .= ShowLine(Op2("=",
			   Op1("second",Op2("pair", $r, $r2)),
			   $r2));
    }

  $txt .= ShowLine(Op2("define",
		       "list-find-helper",
		       Proc("lst",
			    Proc("key",
				 Proc("fail",
				      Proc("idx",
					   Op("if",
					      Op2("=",
						  Op1("list-length",
						      Ref("lst")),
						  0),
					      Op1("fail", 0),
					      Op("if",
						 Op2("equal",
						     Op1("head",Ref("lst")),
						     Ref("key")),
						 Ref("idx"),
						 Op("list-find-helper",
						    Op1("tail",Ref("lst")),
						    Ref("key"),
						    Ref("fail"),
						    Op2("+",
							Ref("idx"),
							1))))))))));
  $txt .= ShowLine(Op2("define",
		       "list-find",
		       Proc("lst",
			    Proc("key",
				 Proc("fail",
				      Op("list-find-helper",
					 Ref("lst"),
					 Ref("key"),
					 Ref("fail"),
					 0))))));
					 


  $txt .= ShowLine(Op2("define",
		       "example-fail",
		       Proc("x",
			    100)));

  for (my $i=0; $i<10; $i++)
    {
      my $len = irand(10)+1;
      my @lst = ();
      for (my $j=0; $j<$len; $j++)
	{
	  push(@lst,irand(20));
	}
      my $idx = irand($len);
      my $val = $lst[$idx];
      my $idx2 = -1;
      for (my $j=0; $j<$len; $j++)
	{
	  if ($lst[$j] == $val)
	    {
	      if ($idx2<0)
		{
		  $idx2 = $j;
		}
	    }
	}
      
      $txt .= ShowLine(Op2("=",
			   Op("list-find",
			      ShowListVerbose(@lst),
			      $val,
			      Ref("example-fail")),
			   $idx2));
    }

  for (my $i=0; $i<3; $i++)
    {
      (my $val, my @lst) = prand(20,5+$i*2);
      $txt .= ShowLine(Op2("=",
			   Op("list-find",
			      ShowListVerbose(@lst),
			      $val,
			      Ref("example-fail")),
			   100));

    }

  return $txt;
}


ShowLesson(ShowListLesson());

