#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowTranslateLesson {
  my $txt = "";
  $txt .= "# HACK describe changes to the implicit interpreter to allow new special forms\n";
  $txt .= ShowLine(Op2("define",
		       "base-translate",
		       Ref("translate")));
  $txt .= ShowLine(Op2("define",
		       "translate",
		       Proc("x",
			    Op("if",
			       Op2("=", Ref("x"), 32),
			       64,
			       Op1("base-translate",
				   Ref("x"))))));
  $txt .= ShowLine(Op2("=", 32, 64));
  $txt .= ShowLine(Op2("=", Op2("+", 32, 64), 128));
  $txt .= ShowLine(Op2("define",
		       "translate",
		       Ref("base-translate")));
  $txt .= ShowLine(Op1("not",Op2("=", 32, 64)));
  $txt .= ShowLine(Op2("=", Op2("+", 32, 64), 96));

  $txt .= "# now can create a special form for lists\n";
  $txt .= ShowLine(Op2("define",
		       "translate",
		       Proc("x",
			    Op("if",
			       Op1("single?", Ref("x")),
			       Op1("base-translate",
				   Ref("x")),
			       Op("if",
				  Op2("=", Op1("head",Ref("x")), "vector"),
				  Op1("translate",
				      Op2("prepend",
					  Op(Op("list", 2),
					     "list",
					     Op1("list-length",
						 Op1("tail",Ref("x")))),
					  Op1("tail",Ref("x")))),
				  Op1("base-translate",Ref("x")))))));

  $txt .= ShowLine(Op2("list=",
		       Op("vector", 1, 2, 3),
		       Op(Op("list", 3), 1, 2, 3)));

  $txt .= "# now to desugar let expressions\n";

  $txt .= ShowLine(Op2("define",
		       "translate-with-vector",
		       Ref("translate")));


  $txt .= ShowLine(Op2("define",
		       "translate-let-form",
		       Proc("x",
			    Proc("body",
				 Op("if",
				    Op2("=",
					Op1("list-length", Ref("x")),
					0),
				    Op1("translate",Ref("body")),
				    Op("translate-let-form",
				       Op1("tail",Ref("x")),
				       Op("vector",
					  Op("vector",
					     "?",
					     Op1("head",Op1("head",Ref("x"))),
					     Ref("body")),
					  Op1("head",Op1("tail",Op1("head",Ref("x")))))))))));

  $txt .= ShowLine(Op2("define",
		       "translate",
		       Proc("x",
			    Op("if",
			       Op1("single?", Ref("x")),
			       Op1("translate-with-vector",
				   Ref("x")),
			       Op("if",
				  Op2("=", Op1("head",Ref("x")), "let"),
				  Op("translate-let-form",
				      Op1("head",
					  Op1("tail",Ref("x"))),
				      Op1("head",
					  Op1("tail",
					      Op1("tail",Ref("x"))))),
				  Op1("translate-with-vector",Ref("x")))))));

  $txt .= ShowLine(Op2("let",
		       Paren(Paren("x",20)),
		       Op2("=", Ref("x"), 20)));

  $txt .= ShowLine(Op2("let",
	       Paren(Paren("x",50), Paren("y",20)),
		       Op2("=", Op2("-",Ref("x"),Ref("y")), 30)));

  return $txt;
};


ShowLesson(ShowTranslateLesson());

