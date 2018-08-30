#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowGraphLesson {
  my $txt = "";
  $txt .= "# MATH introduce graph structures\n";

  $txt .= ShowLine(Op2("define",
		       "make-graph",
		       ProcMultiple(["nodes", "links"],
				    Op2("pair",
					Ref("nodes"), 
					Ref("links")))));

  $txt .= ShowLine(Op2("define",
		       "test-graph",
		       Op("make-graph",
			  ShowList("1", "2", "3", "4"),
			  ShowList(ShowList("1", "2"),
				   ShowList("2", "3"),
				   ShowList("1", "4")))));
		   
  $txt .= ShowLine(Op2("define",
		       "graph-linked",
		       ProcMultiple(["g", "n1", "n2"],
				    Op1("exists",
					Proc("idx",
					     Op("if",
						Op2("and",
						    Op2(">=", Ref("idx"), 0),
						    Op2("<", Ref("idx"),
							Op1("list-length",
							    Op2("list-ref",
								Ref("g"),
								1)))),
						Op2("list=",
						    Op2("list-ref",
							Op2("list-ref",
							    Ref("g"),
							    1),
							 Ref("idx")),
						    ShowList(Ref("n1"),
							     Ref("n2"))),
						Ref("false")))))));
  $txt .= ShowLine(Op2("=",
		       Op("graph-linked", Ref("test-graph"), "1", "2"),
		       Op("true")));
  $txt .= ShowLine(Op2("=",
		       Op("graph-linked", Ref("test-graph"), "1", "3"),
		       Op("false")));
  $txt .= ShowLine(Op2("=",
		       Op("graph-linked", Ref("test-graph"), "2", "4"),
		       Op("false")));
  $txt .= "# 'if' is used a lot in the next definition in place of and/or\n";
  $txt .= "# this is because I haven't established lazy evaluation forms for and/or\n";
  $txt .= "# so this very inefficient algorithm completely bogs down when combined\n";
  $txt .= "# ... during testing with a dumb implementation for 'exists'.\n";
  $txt .= ShowLine(Op2("define",
		       "graph-linked*",
		       ProcMultiple(["g", "n1", "n2"],
				    Op("if",
				       Op2("=", Ref("n1"), Ref("n2")),
				       Ref("true"),
				       Op("if",
					  Op("graph-linked",
					     Ref("g"),
					     Ref("n1"),
					     Ref("n2")),
					  Ref("true"),
					  Op("exists",
					     Proc("n3",
						  Op("if",
						     Op("graph-linked",
							Ref("g"),
							Ref("n1"),
							Ref("n3")),
						     Op("graph-linked*",
							Ref("g"),
							Ref("n3"),
							Ref("n2")),
						     Ref("false")))))))));
							
  $txt .= ShowLine(Op2("=",
		       Op("graph-linked*", Ref("test-graph"), "1", "2"),
		       Op("true")));
  $txt .= ShowLine(Op2("=",
		       Op("graph-linked*", Ref("test-graph"), "1", "3"),
		       Op("true")));
  $txt .= ShowLine(Op2("=",
		       Op("graph-linked*", Ref("test-graph"), "2", "4"),
		       Op("false")));					    

  return $txt;
};


ShowLesson(ShowGraphLesson());

