#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowMutableLesson {
  my $txt = "";
  $txt .= "# MATH introduce mutable objects, and side-effects\n";
  $txt .= ShowLine(Op("intro","make-cell"));
  $txt .= ShowLine(Op("intro","set!"));
  $txt .= ShowLine(Op("intro","get!"));
  $txt .= ShowLine(Op("define",
		      "demo-mut1",
		      Op("make-cell", 0)));
  $txt .= ShowLine(Op2("set!",
		       Ref("demo-mut1"),
		       15));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo-mut1")),
		       15));
  $txt .= ShowLine(Op2("set!",
		       Ref("demo-mut1"),
		       5));
  $txt .= ShowLine(Op2("set!",
		       Ref("demo-mut1"),
		       7));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo-mut1")),
		       7));
  $txt .= ShowLine(Op("define",
		      "demo-mut2",
		      Op("make-cell", 11)));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo-mut2")),
		       11));
  $txt .= ShowLine(Op2("set!",
		       Ref("demo-mut2"),
		       22));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo-mut2")),
		       22));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo-mut1")),
		       7));
  $txt .= ShowLine(Op2("=",
		       Op2("+",
			   Op1("get!", Ref("demo-mut1")),
			   Op1("get!", Ref("demo-mut2"))),
		       29));
  $txt .= ShowLine(Op("if",
		      Op("=",
			 Op1("get!",
			     Ref("demo-mut1")),
			 7),
		      Op2("set!", Ref("demo-mut1"), 88),
		      Op2("set!", Ref("demo-mut1"), 99)));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo-mut1")),
		       88));
  $txt .= ShowLine(Op("if",
		      Op("=",
			 Op1("get!",
			     Ref("demo-mut1")),
			 7),
		      Op2("set!", Ref("demo-mut1"), 88),
		      Op2("set!", Ref("demo-mut1"), 99)));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo-mut1")),
		       99));

  return $txt;
};


ShowLesson(ShowMutableLesson());

