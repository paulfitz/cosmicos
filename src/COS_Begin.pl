#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowTheLesson {
  my $txt = "";
  $txt .= "# MATH show how to execute a sequence of instructions\n";
  $txt .= ShowLine(Op1("intro","begin"));
  $txt .= ShowLine(Op2("define",
		       "prev-translate",
		       Ref("translate")));
  $txt .= ShowLine(Op2("define",
		       "reverse",
		       Proc("x",
			    Op("if",
			       Op2(">=", Op1("list-length",Ref("x")),1),
			       Op2("prepend",
				   Op1("last",Ref("x")),
				   Op1("reverse",Op1("except-last",Ref("x")))),
			       Ref("x")))));

  $txt .= "# test reverse\n";
  $txt .= ShowLine(Op2("list=",
		       ShowList(1,2,3),
		       Op1("reverse",
			   ShowList(3,2,1))));

  $txt .= ShowLine(Op2("define",
		       "translate",
		       Op("let",
			  Paren(Paren("prev",Ref("prev-translate"))),
			  Proc("x",
			       Op("if",
				  Op1("single?", Ref("x")),
				  Op1("prev", Ref("x")),
				  Op("if",
				     Op2("=", Op1("head",Ref("x")), "begin"),
				     Op("translate",
					Op("vector",
					   Op("vector",
					      "?",
					      "x",
					      Op("vector",
						 "last",
						 Op("vector",
						    "x"))),
					   Op("prepend",
					      "vector",
					      Op1("tail",Ref("x"))))),
				     Op1("prev", Ref("x"))))))));
  $txt .= ShowLine(Op2("=",
		       Op("begin", 1, 7, 2, 4),
		       4));
  $txt .= ShowLine(Op2("=",
		       Op("begin",
			  Op2("set!", Ref("demo:make-cell:x"), 88),
			  Op2("set!", Ref("demo:make-cell:x"), 6),
			  Op1("get!", Ref("demo:make-cell:x"))),
		       6));
  $txt .= ShowLine(Op2("=",
		       Op("begin",
			  Op2("set!", Ref("demo:make-cell:y"), 88),
			  Op2("set!", Ref("demo:make-cell:x"), 6),
			  Op1("get!", Ref("demo:make-cell:y"))),
		       88));
  $txt .= ShowLine(Op2("=",
		       Op("begin",
			  Op2("set!", Ref("demo:make-cell:x"), 88),
			  Op2("set!", Ref("demo:make-cell:x"), 6),
			  Op1("get!", Ref("demo:make-cell:x")),
			  4),
		       4));

  return $txt;
};


ShowLesson(ShowTheLesson());

