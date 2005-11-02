#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowTypedGraphLesson {
  my $txt = "";
  $txt .= "# MATH introduce graph structures\n";

  $txt .= "# really need some type templating - will define this later\n";
  $txt .= "# type system needs a little bit of dis-ambiguating!\n";
  $txt .= ShowLine(Op1("pending", "template"));
  $txt .= ShowLine(Op2("define",
		       "tuple",
		       Template(["T"],
				ProcTyped(["lst", Op("listof", Ref("T"))],
					  Op("type",
					     Op("tupleof",
						Ref("T"),
						Op1("list-length", Ref("lst"))),
					     Ref("lst"))))));

  $txt .= ShowLine(Op2("define",
		       "tuple-ref",
		       Template(["T", "len"],
				ProcTyped(["x", Op("tupleof", Ref("T"), Ref("len")),
					   "y", "integer"],
					  Op("list-ref",
					     Op("get-raw", Ref("x")),
					     Op("get-raw", Ref("y")))))));
		   
		   $txt .= ShowLine("define",
				    "make-graph",
				    ProcTyped(["nodes", Op("listof", "integer"),
					       "links", Op("listof", Op("tupleof", "integer", 2))],
					      Op2("type",
						  "graph",
						  Op1("tuple",
						      Op("list",
							 Ref("nodes"), 
							 Ref("links"))))));

  $txt .= ShowLine(Op2("define",
		       "test-graph",
		       Op("make-graph",
			  ShowList("g1", "g2", "g3", "g4"),
			  Op("list",
			     Op("tuple", ShowList("g1", "g2")),
			     Op("tuple", ShowList("g2", "g3")),
			     Op("tuple", ShowList("g1", "g4"))))));
		   
  $txt .= ShowLine(Op2("define",
		       "graph-linked",
		       ProcTyped(["g", "graph",
				  "n1", "integer",
				  "n2", "integer"],
				 Op1("exists",
				     Proc("idx",
					  Op2("=",
					      Op2("tuple-ref",
						  Op2("tuple-ref",
						      Ref("g"),
						      1),
						  Ref("idx")),
					      Op1("tuple",
						  Op("list",
						     Ref("n1"),
						     Ref("n2")))))))));
  $txt .= ShowLine(Op2("=",
		       Op("graph-linked", Ref("test-graph"), "g1", "g2"),
		       Op("true")));
  $txt .= ShowLine(Op2("=",
		       Op("graph-linked", Ref("test-graph"), "g1", "g3"),
		       Op("false")));
  $txt .= ShowLine(Op2("=",
		       Op("graph-linked", Ref("test-graph"), "g2", "g4"),
		       Op("false")));
  $txt .= ShowLine(Op2("define",
		       "graph-linked*",
		       ProcMultiple(["g", "n1", "n2"],
				    Op2("or",
					Op2("=", Ref("n1"), Ref("n2")),
					Op2("or",
					    Op("graph-linked",
					       Ref("g"),
					       Ref("n1"),
					       Ref("n2")),
					    Op("exists",
					       Proc("n3",
						    Op2("and",
							Op("graph-linked",
							   Ref("g"),
							   Ref("n1"),
							   Ref("n3")),
							Op("graph-linked*",
							   Ref("g"),
							   Ref("n3"),
							   Ref("n2"))))))))));
							
  $txt .= ShowLine(Op2("=",
		       Op("graph-linked*", Ref("test-graph"), "g1", "g2"),
		       Op("true")));
  $txt .= ShowLine(Op2("=",
		       Op("graph-linked*", Ref("test-graph"), "g1", "g3"),
		       Op("true")));
  $txt .= ShowLine(Op2("=",
		       Op("graph-linked*", Ref("test-graph"), "g2", "g4"),
		       Op("false")));					    

  return $txt;
};


ShowLesson(ShowTypedGraphLesson());

