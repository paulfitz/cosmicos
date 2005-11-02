#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowMethodLesson {
  my $txt = "";
  
  $txt .= "# OBJECT introduce method handler wrappers\n";

  $txt .= ShowLine(Op2("define",
		       "add-method",
		       ProcMultiple(["object","name","method"],
				    Op("hash-add",
				       Ref("object"),
				       Ref("name"),
				       Proc("dummy",
					    Op1("method",Ref("object")))))));

  $txt .= ShowLine(Op2("define",
		       "call",
		       Proc("x",
			    Op("x",
			       0))));

#  $txt .= ShowLine(Op2("define",
#		       "mutable-struct",
#		       Proc("lst",
#			    Op("let",
#			       Paren(Paren("data",
#					   Op2("map",
#					       Proc("x", 
#						    Op1("make-cell", 0)),
#					       Ref("lst")))),
#			       Proc("key",
#				    Op("list-ref",
#				       Ref("data"),
#				       Op("find-list",
#					  Ref("lst"),
#					  Ref("key"))))))));
  

  $txt .= ShowLine(Op2("define",
		       "test-struct2",
		       Op1("mutable-struct",
			   ShowList("x", "y"))));
  $txt .= ShowLine(Op2("set!",
		       Op("test-struct2", "x"),
		       10));
  $txt .= ShowLine(Op2("set!",
		       Op("test-struct2", "y"),
		       20));
  $txt .= ShowLine(Op2("=",
		       Op1("get!",
			   Op("test-struct2", "x")),
		       10));
  $txt .= ShowLine(Op2("=",
		       Op1("get!",
			   Op("test-struct2", "y")),
		       20));
  $txt .= ShowLine(Op2("define",
		       "test-struct3",
		       Op("add-method",
			  Ref("test-struct2"),
			  "sum",
			  Proc("self",
			       Op2("+",
				   Op1("get!",Op("self","x")),
				   Op1("get!",Op("self","y")))))));
  $txt .= ShowLine(Op2("=",
		       Op1("get!",
			   Op("test-struct3", "x")),
		       10));
  $txt .= ShowLine(Op2("=",
		       Op1("get!",
			   Op("test-struct3", "y")),
		       20));
  $txt .= ShowLine(Op2("=",
		       Op1("call",Op("test-struct3", "sum")),
		       30));
  $txt .= ShowLine(Op2("set!",
		       Op("test-struct3", "y"),
		       10));
  $txt .= ShowLine(Op2("=",
		       Op1("call",Op("test-struct3", "sum")),
		       20));
  $txt .= ShowLine(Op2("set!",
		       Op("test-struct2", "y"),
		       5));
  $txt .= ShowLine(Op2("=",
		       Op1("call",Op("test-struct3", "sum")),
		       15));

  return $txt;
}


ShowLesson(ShowMethodLesson());

