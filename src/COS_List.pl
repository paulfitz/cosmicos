#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowListLesson {
  my $txt = "";

  $txt .= "# the is-list function is now on dubious ground\n";
  $txt .= "# this stuff will be replaced with typing ASAP\n";

  $txt .= ShowLine(Op("define",
		      "is-list",
		      Proc("x",
			   Op1("not",
			       Op1("number?",
				   Ref("x"))))));
  $txt .= ShowLine(Op1("is-list",
		       ShowListVerbose(1, 3)));
  $txt .= ShowLine(Op1("is-list",
		       ShowListVerbose()));
  $txt .= ShowLine(Op1("not",
		       Op1("is-list",
			   23)));
#  $txt .= ShowLine(Op1("not",
#		       Op1("is-list",
#			   Proc("x", Op2("+", Ref("x"), 10)))));
  $txt .= ShowLine(Op1("is-list",
		       ShowListVerbose(ShowListVerbose(2, 3), 1, Proc("x", Op2("+", Ref("x"), 10)))));

  return $txt;
}


ShowLesson(ShowListLesson());

