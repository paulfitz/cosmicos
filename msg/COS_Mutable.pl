#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowMutableLesson {
  my $txt = "";
  $txt .= ShowLine(Op("intro","make-cell"));
  $txt .= ShowLine(Op("intro","set!"));
  $txt .= ShowLine(Op("intro","get!"));
  $txt .= ShowLine(Op("define",
		      "demo:make-cell:x",
		      TailOp("make-cell", 14)));
  $txt .= "= (get! \$demo:make-cell:x) 14;\n";
  $txt .= ShowLine(Op2("set!",
		       Ref("demo:make-cell:x"),
		       15));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo:make-cell:x")),
		       15));
  $txt .= ShowLine(Op2("set!",
		       Ref("demo:make-cell:x"),
		       5));
  $txt .= ShowLine(Op2("set!",
		       Ref("demo:make-cell:x"),
		       7));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo:make-cell:x")),
		       7));
  $txt .= ShowLine(Op("define",
		      "demo:make-cell:y",
		      Op("make-cell", 11)));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo:make-cell:y")),
		       11));
  $txt .= ShowLine(Op2("set!",
		       Ref("demo:make-cell:y"),
		       22));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo:make-cell:y")),
		       22));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo:make-cell:x")),
		       7));
  $txt .= ShowLine(Op2("=",
		       29,
		       TailOp2("+",
			       Op1("get!", Ref("demo:make-cell:x")),
			       Op1("get!", Ref("demo:make-cell:y")))));
  $txt .= ShowLine(Op("if",
		      Op("=",
			 Op1("get!",
			     Ref("demo:make-cell:x")),
			 7),
		      Op2("set!", Ref("demo:make-cell:x"), 88),
		      Op2("set!", Ref("demo:make-cell:x"), 99)));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo:make-cell:x")),
		       88));
  $txt .= ShowLine(Op("if",
		      Op("=",
			 Op1("get!",
			     Ref("demo:make-cell:x")),
			 7),
		      Op2("set!", Ref("demo:make-cell:x"), 88),
		      Op2("set!", Ref("demo:make-cell:x"), 99)));
  $txt .= ShowLine(Op2("=",
		       Op1("get!", Ref("demo:make-cell:x")),
		       99));

  return $txt;
};


ShowLesson(ShowMutableLesson());

