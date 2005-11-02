#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowImplicationLesson {
  my $txt = "";
  $txt .= "# MATH introduce logical implication\n";
  $txt .= ShowLine(Op("intro","=>"));
  $txt .= ShowLine(Op("define",
		      "=>",
		      Proc("x",
			   Proc("y",
				Op1("not",
				    Op2("and",
					Ref("x"),
					Op1("not",
					    Ref("y"))))))));
  $txt .= ShowLine(Op2("=>",ShowTrue(),ShowTrue()));
  $txt .= ShowLine(Op1("not",Op2("=>",ShowTrue(),ShowFalse())));
  $txt .= ShowLine(Op2("=>",ShowFalse(),ShowTrue()));
  $txt .= ShowLine(Op2("=>",ShowFalse(),ShowFalse()));
  $txt .= ShowLine(Op("forall",
		      Proc(Lit("x"),
			   Op("forall",
			      Proc(Lit("y"),
				   Op2("=>",
				       Op2("=>",
					   Ref("x"),
					   Ref("y")),
				       Op2("=>",
					   Op1("not",Ref("y")),
					   Op1("not",Ref("x")))))))));
  return $txt;
};


ShowLesson(ShowImplicationLesson());

