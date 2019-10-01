#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowMutableStructureLesson {
  my $txt = "";
  $txt .= "# OBJECT introduce simple mutable structures\n";
  $txt .= ShowLine(Op2("define",
		       "mutable-struct",
		       Proc("lst",
			    Op("let",
			       Paren(Paren("data",
					   Op2("map",
					       Proc("x", 
						    Op1("make-cell", 0)),
					       Ref("lst")))),
			       Proc("key",
				    Op("list-ref",
				       Ref("data"),
				       Op("list:find",
					  Ref("lst"),
					  Ref("key"))))))));

  

  $txt .= ShowLine(Op2("define",
		       "test-struct1",
		       Op1("mutable-struct",
			   ShowList("item1", "item2", "item3"))));
  $txt .= ShowLine(Op2("set!",
		       Op("test-struct1", "item1"),
		       15));
  $txt .= ShowLine(Op2("=",
		       Op1("get!",
			   Op("test-struct1", "item1")),
		       15));

  return $txt;
};


ShowLesson(ShowMutableStructureLesson());

