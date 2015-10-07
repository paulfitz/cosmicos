#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowMultipleParameterLesson {
  my $txt = "";
  $txt .= "# MATH build up functions of several variables\n";
  for (my $i=0; $i<5; $i++)
    {
      my $r2 = irand(10);
      my $r1 = irand(10)+$r2;
      $txt .= ShowLine(Op2("=",
			   Apply(Proc("x",
				      Proc("y",
					   Op2("-",Ref("x"),Ref("y")))),
				 $r1,
				 $r2),
			   Num($r1-$r2)));
    }
  $txt .= ShowLine(Op2("define",
		       "last",
		       Proc("x",
			    Op2("list-ref", 
				Ref("x"),
				Op2("-", Op1("list-length",Ref("x")), 1)))));

  $txt .= ShowLine(Op2("define",
		       "except-last",
		       Proc("x",
			    Op("if", 
			       Op2(">",
				   Op1("list-length",Ref("x")),
				   1),
			       Op2("prepend",
				   Op1("head", Ref("x")),
				   Op1("except-last",
				       Op1("tail", Ref("x")))),
			       Op("vector")))));

  $txt .= "# test last and except-last\n";
  $txt .= ShowLine(Op2("=",
		       15,
		       Op1("last",
			   Op("vector", 4, 5, 15))));

  $txt .= ShowLine(Op2("list=",
		       Op("vector", 4, 5),
		       Op1("except-last",
			   Op("vector", 4, 5, 15))));

  $txt .= ShowLine(Op1("intro", "lambda"));
  $txt .= ShowLine(Op2("define",
		       "prev-translate",
		       Ref("translate")));
  $txt .= ShowLine(Op2("define",
		       "translate",
		       Op("let",
			  Paren(Paren("prev",Ref("prev-translate"))),
			  Proc("x",
			       Op("if",
				  Op1("single?", Ref("x")),
				  Op1("prev", Ref("x")),
				  Op("if",
				     Op2("=", Op1("head",Ref("x")), "lambda"),
				     Op("let",
					Paren(Paren("formals",
						    Op1("head",
							Op1("tail",
							    Ref("x")))),
					      Paren("body",
						    Op1("head",
							Op1("tail",
							    Op1("tail",
								Ref("x")))))),
					Op("if",
					   Op2(">",
					       Op1("list-length",
						   Ref("formals")),
					       0),
					   Op("translate",
					      Op("vector",
						 "lambda",
						 Op1("except-last",
						     Ref("formals")),
						 Op("vector",
						    "?",
						    Op1("last",Ref("formals")),
						    Ref("body")))),
					   Op("translate",
					      Ref("body")))),
				      Op1("prev", Ref("x"))))))));

  $txt .= "# test lambda\n";

#  $txt .= "# " . ShowLine(Op2("=",
#		       Proc("x",
#			    Op2("-",Ref("x"),5)),
#		       ProcMultiple(["x"],
#			    Op2("-",Ref("x"),5))));
#  $txt .= "# " . ShowLine(Op2("=",
#		       Proc("x",
#			    Proc("y",
#				 Op2("-",Ref("x"),Ref("y")))),
#		       ProcMultiple(["x", "y"],
#			    Op2("-",Ref("x"),Ref("y")))));
		       
  for (my $i=0; $i<5; $i++)
    {
      my $r2 = irand(10);
      my $r1 = irand(10)+$r2;
      $txt .= ShowLine(Op2("=",
			   Apply(ProcMultiple(["x","y"],
					      Op2("-",Ref("x"),Ref("y"))),
				 $r1,
				 $r2),
			   Num($r1-$r2)));
    }
  $txt .= ShowLine(Op2("define",
		       "apply",
		       ProcMultiple(["x","y"],
				    Op("if",
				       Op2("list=",
					   Ref("y"),
					   Op("vector")),
				       Ref("x"),
				       Op2("apply",
					   Apply(Ref("x"),
						 Op1("head", Ref("y"))),
					   Op1("tail", Ref("y")))))));
					   
  for (my $i=0; $i<5; $i++)
    {
      my $r2 = irand(10);
      my $r1 = irand(10)+$r2;
      $txt .= ShowLine(Op2("=",
			   Op2("apply",
			       ProcMultiple(["x","y"],
					    Op2("-",Ref("x"),Ref("y"))),
			       ShowList(
				  $r1,
				  $r2)),
			   Num($r1-$r2)));
    }
  return $txt;
};


ShowLesson(ShowMultipleParameterLesson());

