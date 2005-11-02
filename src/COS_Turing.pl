#!/usr/bin/perl -w
use strict;

use cosmic;

#my $empty = "(false)";
my $empty = "(vector)";

sub ShowTuringLesson {
  my $txt .= "# TURING introduce turing machine model\n";
  $txt .= "# just for fun!\n";
  $txt .= ShowLine(Op2("define",
		       "safe-tail",
		       Proc("x",
			    Op("if",
			       Op2(">",
				   Op1("list-length",Ref("x")),
				   0),
			       Op("if",
				  Op2(">",
				      Op1("list-length",Ref("x")),
				      1),
				  Op1("tail",Ref("x")),
				  Op1("vector",$empty)),
			       Op1("vector", $empty)))));
  $txt .= ShowLine(Op2("define",
		       "safe-head",
		       Proc("x",
			    Op("if",
			       Op2(">",
				   Op1("list-length",Ref("x")),
				   0),
			       Op1("head",Ref("x")),
			       $empty))));

  $txt .= ShowLine(Op2("define",
		       "tape-read",
		       Proc("tape",
			    Op("let",
			       Paren(Paren("x",
					   Op1("second",Ref("tape")))),
			       Op("if",
				  Op2(">",
				      Op1("list-length",Ref("x")),
				      0),
				  Op1("head",Ref("x")),
				  $empty)))));

  $txt .= ShowLine(Op2("define",
		       "tape-transition",
		       ProcMultiple(["tape","shift","value"],
				    Op("if",
				       Op2("=", Ref("shift"), 1),
				       Op2("pair",
					   Op2("prepend",
					       Ref("value"),
					       Op1("first",Ref("tape"))),
					   Op1("safe-tail",
					       Op1("second",Ref("tape")))),
				       Op("if",
					  Op2("=", Ref("shift"), 0),
					  Op2("pair",
					      Op1("safe-tail",
						  Op1("first",Ref("tape"))),
					      Op2("prepend",
						  Op1("safe-head",
						      Op1("first",
							  Ref("tape"))),
						  Op2("prepend",
						      Ref("value"),
						      Op1("safe-tail",
							  Op1("second",
							      Ref("tape")))))),
					  Op2("pair",
					      Op1("first",Ref("tape")),
					      Op2("prepend",
						  Ref("value"),
						  Op1("safe-tail",
						      Op1("second",
							  Ref("tape"))))))))));



  $txt .= ShowLine(Op2("define",
		       "turing",
		       ProcMultiple(["machine", "current", "last", "tape"],
				    Op("if",
				       Op2("=",Ref("current"),Ref("last")),
				       Ref("tape"),
				       Op("let",
					  Paren(Paren("next",
						      Op("machine",
							 Ref("current"),
							 Op1("tape-read",
							     Ref("tape"))))),
					  Op("turing",
					     Ref("machine"),
					     Op2("list-ref",
						 Ref("next"),
						 0),
					     Ref("last"),
					     Op("tape-transition",
						Ref("tape"),
						Op2("list-ref",
						    Ref("next"),
						    1),
						Op2("list-ref",
						    Ref("next"),
						    2))))))));
						   

  $txt .= ShowLine(Op2("define",
		       "make-tape",
		       Proc("x",
			    Op2("pair",
				Op("vector"),
				Ref("x")))));

  $txt .= ShowLine(Op2("define",
		       "remove-trail",
		       Proc("x",
			    Proc("lst",
				 Op("if",
				    Op2(">", Op1("list-length",Ref("lst")), 0),
				    Op("if",
				       Op2("equal", 
					   Op1("last",Ref("lst")), 
					   Ref("x")),
				       Op2("remove-trail", 
					   Ref("x"),
					   Op1("except-last", Ref("lst"))),
				       Ref("lst")),
				    Ref("lst"))))));
			    

  $txt .= ShowLine(Op2("define",
		       "extract-tape",
		       Proc("x",
			    Op2("remove-trail",
				$empty,
				Op1("second",
				    Ref("x"))))));


  $txt .= ShowLine(Op2("define",
		       "tm-binary-increment",
		       Op1("make-hash",
			   ShowList(Op2("pair",
					"right",
					Op1("make-hash",
					    ShowList(Op2("pair",
							 0,
							 ShowList("right",1,0)),
						     Op2("pair",
							 1,
							 ShowList("right",1,1)),
						     Op2("pair",
							 $empty,
							 ShowList("inc",0,$empty))))),
				    Op2("pair",
					"inc",
					Op1("make-hash",
					    ShowList(Op2("pair",
							 0,
							 ShowList("noinc",0,1)),
						     Op2("pair",
							 1,
							 ShowList("inc",0,0)),
						     Op2("pair",
							 $empty,
							 ShowList("halt",2,1))))),
				    Op2("pair",
					"noinc",
					Op1("make-hash",
					    ShowList(Op2("pair",
							 0,
							 ShowList("noinc",0,0)),
						     Op2("pair",
							 1,
							 ShowList("noinc",0,1)),
						     Op2("pair",
							 $empty,
							 ShowList("halt",1,$empty))))),
				    Op2("pair",
					"halt",
					Op1("make-hash",
					    ShowList()))))));


  $txt .= ShowLine(Op2("list=",
		       Op1("extract-tape",
			   Op("turing",
			      Ref("tm-binary-increment"),
			      "right",
			      "halt",
			      Op1("make-tape",
				  ShowList(1,0,0,1)))),
		       ShowList(1,0,1,0)));


  $txt .= ShowLine(Op2("list=",
		       Op1("extract-tape",
			   Op("turing",
			      Ref("tm-binary-increment"),
			      "right",
			      "halt",
			      Op1("make-tape",
				  ShowList(1,1,1)))),
		       ShowList(1,0,0,0)));
  $txt .= ShowLine(Op2("list=",
		       Op1("extract-tape",
			   Op("turing",
			      Ref("tm-binary-increment"),
			      "right",
			      "halt",
			      Op1("make-tape",
				  ShowList(1,1,1,0,0,0,1,1,1)))),
		       ShowList(1,1,1,0,0,1,0,0,0)));
		   
  return $txt;
}


ShowLesson(ShowTuringLesson());

