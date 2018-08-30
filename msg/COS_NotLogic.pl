#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowNotLogicLesson {
  my $txt = "";

#  $txt .= "# SYNTAX introduce tail notation\n";
#  $txt .= "# I've recently added the / symbol to reduce the need\n";
#  $txt .= "# for unnecessary levels of nesting and parentheses.\n";
#  $txt .= "# This might be a little early to talk about it, since it\n";
#  $txt .= "# is most valuable for complex expressions.\n";
#  $txt .= "(= 0110 0110)\n";
#  $txt .= "(= 0110 / 0110)\n";
#  $txt .= "(< (unary 1 1 0) (unary 1 1 1 1 0))\n";
#  $txt .= "(< (unary 1 1 0) / unary 1 1 1 1 0)\n";
#  $txt .= "(> (unary 1 1 0) (unary 1 0))\n";
#  $txt .= "(> (unary 1 1 0) / unary 1 0)\n";
#	$txt

  $txt .= "# MATH introduce the NOT logical operator\n";

  $txt .= ShowLine(Op("intro","not"));

  my @example;
  my @example2;
  @example = prand(10,5);
  for (my $i=0; $i<=$#example; $i++)
    {
      my $r = $example[$i];
      #print "@example";
      #exit(1);
      $txt .= ShowLine(Op2("=",ShowUnary($r),ShowUnary($r)));
      $txt .= ShowLine(TailOp1("not",Op2("<",ShowUnary($r),ShowUnary($r))));
      $txt .= ShowLine(TailOp1("not",Op2(">",ShowUnary($r),ShowUnary($r))));
    }
  @example = prand(10,5);
  @example2 = prand(10,5);
  for (my $i=0; $i<=$#example; $i++)
    {
      my $r = $example[$i];
      my $r2 = $r+1+$example2[$i];
      $txt .= ShowLine(TailOp1("not",Op2("=",ShowUnary($r),ShowUnary($r2))));
      $txt .= ShowLine(Op2("<",ShowUnary($r),ShowUnary($r2)));
      $txt .= ShowLine(TailOp1("not",Op2(">",ShowUnary($r),ShowUnary($r2))));
    }
  @example = prand(10,5);
  @example2 = prand(10,5);
  for (my $i=0; $i<=$#example; $i++)
    {
      my $r = $example[$i];
      my $r2 = $r+1+$example2[$i];
      $txt .= ShowLine(TailOp1("not",Op2("=",ShowUnary($r2),ShowUnary($r))));
      $txt .= ShowLine(Op2(">",ShowUnary($r2),ShowUnary($r)));
      $txt .= ShowLine(TailOp1("not",Op2("<",ShowUnary($r2),ShowUnary($r))));
    }

  return $txt;
};


ShowLesson(ShowNotLogicLesson());

