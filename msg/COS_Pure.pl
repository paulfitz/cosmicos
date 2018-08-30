#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowPureLesson {
  my $txt = "";
  $txt .= "# MATH some pure lambda calculus definitions - optional\n";
  $txt .= "# these definitions are not quite what we want\n";
  $txt .= "# since thinking of everything as a function requires headscratching\n";
  $txt .= "# it would be better to use these as a parallel means of evaluation\n";
  $txt .= "# ... for expressions\n";
  $txt .= ShowLine(Op2("define",
		       "pure-if",
		       Proc(Lit("x"),
			    Proc(Lit("y"),
				 Proc(Lit("z"),
				      Apply("x",
					    Ref("y"),
					    Ref("z")))))));
  $txt .= ShowLine(Op2("define",
		       "pure-true",
		       Proc(Lit("y"),
			    Proc(Lit("z"),
				 Apply("y")))));
  $txt .= ShowLine(Op2("define",
		       "pure-false",
		       Proc(Lit("y"),
			    Proc(Lit("z"),
				 Apply("z")))));
  $txt .= ShowLine(Op2("define",
		       "pure-cons",
		       Proc(Lit("x"),
			    Proc(Lit("y"),
				 Proc(Lit("z"),
				      Op("pure-if",
					 Ref("z"),
					 Ref("x"),
					 Ref("y")))))));
  $txt .= ShowLine(Op2("define",
		       "pure-car",
		       Proc(Lit("x"),
			    Apply(Lit("x"),
				  Ref("pure-true")))));
  $txt .= ShowLine(Op2("define",
		       "pure-cdr",
		       Proc(Lit("x"),
			    Apply(Lit("x"),
				  Ref("pure-false")))));
  $txt .= ShowLine(Op2("define",
		       "zero",
		       Proc("f",
			    Proc("x",Ref("x")))));
  $txt .= ShowLine(Op2("define",
		       "one",
		       Proc("f",
			    Proc("x",
				 Apply("f",
				       Ref("x"))))));
  $txt .= ShowLine(Op2("define",
		       "two",
		       Proc("f",
			    Proc("x",
				 Apply("f",
				       Apply("f",
					     Ref("x")))))));
  $txt .= ShowLine(Op2("define",
		       "succ",
		       Proc(Lit("n"),
			    Proc("f",
				 Proc("x",
				      Apply("f",
					    Apply(Apply("n", Ref("f")),
						  Ref("x"))))))));

  $txt .= ShowLine(Op2("define",
		       "add",
		       Proc("a",
			    Proc("b",
				 Apply(Apply("a", Ref("succ")),
				       Ref("b"))))));
  $txt .= ShowLine(Op2("define",
		       "mult",
		       Proc("a",
			    Proc("b",
				 Apply(Apply("a", Op1("add", Ref("b"))),
				       Ref("zero"))))));
  $txt .= ShowLine(Op2("define",
		       "pred",
		       Proc("n",
			    Op1("pure-cdr",
				Apply(Apply("n",
					    Proc("p",
						 Op2("pure-cons",
						     Op1("succ", 
							 Op1("pure-car", Ref("p"))),
						     Op1("pure-car", Ref("p"))))),
				      Op2("pure-cons", Ref("zero"), Ref("zero")))))));
  $txt .= ShowLine(Op2("define",
		       "is-zero",
		       Proc("n",
			    Apply(Apply("n",
					Proc("dummy",
					     Ref("pure-false")),
					Ref("pure-true"))))));
					

  $txt .= ShowLine(Op2("define",
		       "fixed-point",
		       Proc("f",
			    Apply(Proc(Lit("x"),
				       Apply("f",
					     Apply("x",
						   Ref("x")))),
				  Proc(Lit("x"),
				       Apply("f",
					     Apply("x",
						   Ref("x"))))))));

  $txt .= "# .. but for rest of message will assume that define does fixed-point for us\n";

  $txt .= "# now build a link between numbers and church number functions\n";
  $txt .= ShowLine(Op2("define",
		       "unchurch",
		       Proc("c",
			    Op("c",
			       Proc("x", Op2("+", Ref("x"), 1)),
			       0))));
  $txt .= ShowLine(Op2("=",
		       0,
		       Op1("unchurch", Ref("zero"))));
  $txt .= ShowLine(Op2("=",
		       1,
		       Op1("unchurch", Ref("one"))));
  $txt .= ShowLine(Op2("=",
		       2,
		       Op1("unchurch", Ref("two"))));
  $txt .= ShowLine(Op2("define",
		       "church",
		       Proc("x",
			    Op("if",
			       Op2("=",
				   0,
				   Ref("x")),
			       Ref("zero"),
			       Op1("succ",
				   Op1("church",
				       Op2("-", Ref("x"), 1)))))));


  return $txt;
};


ShowLesson(ShowPureLesson());

