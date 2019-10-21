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
  $txt .= "intro pure:if;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:if",
		       Proc(Lit("x"),
			    Proc(Lit("y"),
				 Proc(Lit("z"),
				      Apply("x",
					    Ref("y"),
					    Ref("z")))))));
  $txt .= "intro pure:true;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:true",
		       Proc(Lit("y"),
			    Proc(Lit("z"),
				 Apply("y")))));
  $txt .= "intro pure:false;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:false",
		       Proc(Lit("y"),
			    Proc(Lit("z"),
				 Apply("z")))));
  $txt .= "intro pure:cons;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:cons",
		       Proc(Lit("x"),
			    Proc(Lit("y"),
				 Proc(Lit("z"),
				      Op("pure:if",
					 Ref("z"),
					 Ref("x"),
					 Ref("y")))))));
  $txt .= "intro pure:car;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:car",
		       Proc(Lit("x"),
			    Apply(Lit("x"),
				  Ref("pure:true")))));
  $txt .= "intro pure:cdr;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:cdr",
		       Proc(Lit("x"),
			    Apply(Lit("x"),
				  Ref("pure:false")))));
  $txt .= "intro pure:0;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:0",
		       Proc("y",
			    Proc("x",Ref("x")))));
  $txt .= "intro pure:1;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:1",
		       Proc("y",
			    Proc("x",
				 Apply("y",
				       Ref("x"))))));
  $txt .= "intro pure:2;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:2",
		       Proc("y",
			    Proc("x",
				 Apply("y",
				       Apply("y",
					     Ref("x")))))));
  $txt .= "intro pure:next;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:next",
		       Proc(Lit("n"),
			    Proc("y",
				 Proc("x",
				      Apply("y",
					    Apply(Apply("n", Ref("y")),
						  Ref("x"))))))));

  $txt .= "intro pure:+;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:+",
		       Proc("x",
			    Proc("y",
				 Apply(Apply("x", Ref("pure:next")),
				       Ref("y"))))));
  $txt .= "intro pure:*;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:*",
		       Proc("x",
			    Proc("y",
				 Apply(Apply("x", Op1("pure:+", Ref("y"))),
				       Ref("pure:0"))))));
  $txt .= "intro pure:prev;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:prev",
		       Proc("x:pure",
			    Op1("pure:cdr",
				Apply(Apply("x:pure",
					    Proc("x:?",
						 Op2("pure:cons",
						     Op1("pure:next", 
							 Op1("pure:car", Ref("x:?"))),
						     Op1("pure:car", Ref("x:?"))))),
				      Op2("pure:cons", Ref("pure:0"), Ref("pure:0")))))));
  $txt .= "intro pure:=:0;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:=:0",
		       Proc("x:pure",
			    Apply(Apply("x:pure",
					Proc("y",
					     Ref("pure:false")),
					Ref("pure:true"))))));
					

  $txt .= "intro fixed-point;\n";
  $txt .= ShowLine(Op2("define",
		       "fixed-point",
		       Proc("x",
			    Apply(Proc(Lit("y"),
				       Apply("x",
					     Apply("y",
						   Ref("y")))),
				  Proc(Lit("y"),
				       Apply("x",
					     Apply("y",
						   Ref("y"))))))));

  $txt .= "# .. but for rest of message will assume that define does fixed-point for us\n";

  $txt .= "# now build a link between numbers and church number functions\n";
  $txt .= "intro pure:int:get;\n";
  $txt .= ShowLine(Op2("define",
		       "pure:int:get",
		       Proc("y",
			    Op("y",
			       Proc("x", Op2("+", Ref("x"), 1)),
			       0))));
  $txt .= ShowLine(Op2("=",
		       0,
		       Op1("pure:int:get", Ref("pure:0"))));
  $txt .= ShowLine(Op2("=",
		       1,
		       Op1("pure:int:get", Ref("pure:1"))));
  $txt .= ShowLine(Op2("=",
		       2,
		       Op1("pure:int:get", Ref("pure:2"))));
  $txt .= ShowLine(Op2("define",
		       "int:pure:get",
		       Proc("x",
			    Op("if",
			       Op2("=",
				   0,
				   Ref("x")),
			       Ref("pure:0"),
			       Op1("pure:next",
				   Op1("int:pure:get",
				       Op2("-", Ref("x"), 1)))))));


  return $txt;
};


ShowLesson(ShowPureLesson());

