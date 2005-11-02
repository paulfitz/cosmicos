#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowEvaluationLesson {
  my $txt = "";
  $txt .= "# MATH show local assignment\n";
  for (my $i=20; $i<23; $i++) {
      for (my $j=0; $j<3; $j++) {
	  $txt .= "(assign $i $j / = ($i) $j);\n";
      }
  }
  for (my $i=20; $i<23; $i++) {
      for (my $j=0; $j<3; $j++) {
	  $txt .= "(= $j (assign $i $j ($i)));\n";
	  $txt .= "(= $j (assign $i $j / $i));\n";
	  $txt .= "(= $j / assign $i $j / $i);\n";
	  $txt .= "(= $i / assign $i $j $i);\n";
	  $txt .= "(= 5 / assign $i $j 5);\n";
	  $txt .= "(= 5 / assign $i $j / assign 23 5 / 23);\n";
	  $txt .= "(= 23 / assign $i $j / assign 23 5 23);\n";
      }
  }
  $txt .= "# Now for functions.\n";
  for (my $k=0; $k<3; $k++) {
      for (my $i=5; $i<=6; $i++) {
	  for (my $j=2; $j<=3; $j++) {
	      my ($q1, $q2) = prand(20,2);
	      $q1 = $q1+20;
	      $q2 = $q2+20;
	      if ($k==0) {
		  $txt .= "(assign $q1 (? $q2 $i) / = $i ($q1 $j));\n";
	      } elsif ($k==1) {
		  $txt .= "(assign $q1 (? $q2 ($q2)) / = $j ($q1 $j));\n";
	      } elsif ($k==2) {
		  $txt .= "(assign $q1 (? $q2 / + ($q2) 1) / = " . ($j+1) . " ($q1 $j));\n";
	      }
	  }
      }
  }
  for (my $i=0; $i<4; $i++)
    {
      my $r = irand(16);
      my $r2 = irand(16);
      $txt .= "(assign y (? x / + (x) $r) / = (y $r2) " . ($r+$r2) . ");\n";
      $txt .= "(= ((? x / + (x) $r) $r2) " . ($r+$r2) . ");\n";
#      $txt .= ShowLine(Apply(Proc(Lit("x"),
#				  TailOp2("=",
#				      Num($r+$r2),
#				      TailOp2("+",Num($r),Ref("x")))),
#			     Num($r2)));
    }
  for (my $i=0; $i<4; $i++)
    {
      my $r = irand(16);
      my $r2 = irand(16);
      $txt .= "(assign z (? x / ? y / + 1 / * (x) (y)) / = (z $r $r2) " . (1+$r*$r2) . ");\n";
      $txt .= "(assign z (? x / ? y / + 1 / * (x) (y)) / = ((z $r) $r2) " . (1+$r*$r2) . ");\n";
      $txt .= "(= ((? x / ? y / + 1 / * (x) (y)) $r $r2) " . (1+$r*$r2) . ");\n";
      $txt .= "(= (((? x / ? y / + 1 / * (x) (y)) $r) $r2) " . (1+$r*$r2) . ");\n";
#      $txt .= ShowLine(Apply(Apply(Proc(Lit("x"),
#					Proc(Lit("y"),
#					     TailOp2("=",
#						 Num($r*$r2),
#						 Op2("*",
#						     Ref("x"),
#						     Ref("y"))))),
#				   Num($r)),
#			     Num($r2)));
    }
  for (my $i=0; $i<8; $i++)
    {
      my $r = irand(16);
      my $r2 = irand(16);
      $txt .= "(assign w (? x / ? y / ? z / = (z) / + (x) (y)) / w $r $r2 " . ($r+$r2) . ");\n";
#      $txt .= ShowLine(Apply(Apply(Apply(Proc(Lit("z"),
#					      Proc(Lit("x"),
#						   Proc(Lit("y"),
#							TailOp2("=",
#							    Ref("z"),
#							    Op2("*",
#								Ref("x"),
#								Ref("y")))))),
#					 Num($r*$r2)),
#				   Num($r)),
#			     Num($r2)));
    }
  return $txt;
};


ShowLesson(ShowEvaluationLesson());

