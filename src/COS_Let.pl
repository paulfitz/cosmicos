#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowLetLesson {
  my $txt = "";
  $txt .= "# MATH introduce sugar for let\n";
  $txt .= "# if would be good to introduce desugarings more rigorously, but for now...\n";
  $txt .= "# ... just a very vague sketch\n";
  $txt .= ShowLine(Op1("intro", "let"));
  $txt .= ShowLine(Op2("=",
		       Op("let",
			  Paren(Paren("x",10)),
			  Op2("+", Ref("x"), 5)),
		       Apply(Proc("x",
				  Op2("+", Ref("x"), 5)),
			     10)));
  $txt .= ShowLine(Op2("=",
		       Op("let",
			  Paren(Paren("x",10),Paren("y",5)),
			  Op2("+", Ref("x"), Ref("y"))),
		       Apply(Apply(Proc("x",
					Proc("y",
					     Op2("+", Ref("x"), Ref("y")))),
				   10),
			     5)));
  return $txt;
};


ShowLesson(ShowLetLesson());

