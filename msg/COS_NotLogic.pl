#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowNotLogicLesson {
  my $txt = "";

  $txt .= ShowLine(Op("intro","not"));

  $txt .= ShowDoc("Show an equality, then negate two conflicting inequalities.");

  my @example;
  my @example2;
  @example = prand(10,5);
  for (my $i=0; $i<=$#example; $i++)
    {
      my $r = $example[$i];
      $txt .= ShowLine(Op2("=",ShowUnary($r),ShowUnary($r)));
      $txt .= ShowLine(TailOp1("not",Op2("<",ShowUnary($r),ShowUnary($r))));
      $txt .= ShowLine(TailOp1("not",Op2(">",ShowUnary($r),ShowUnary($r))));
    }
  $txt .= ShowDoc("Show an inequality, then two negations.");
  @example = prand(10,5);
  @example2 = prand(10,5);
  for (my $i=0; $i<=$#example; $i++)
    {
      my $r = $example[$i];
      my $r2 = $r+1+$example2[$i];
      $txt .= ShowLine(Op2("<",ShowUnary($r),ShowUnary($r2)));
      $txt .= ShowLine(TailOp1("not",Op2("=",ShowUnary($r),ShowUnary($r2))));
      $txt .= ShowLine(TailOp1("not",Op2(">",ShowUnary($r),ShowUnary($r2))));
    }
  $txt .= ShowDoc("Show another batch of inequalities with negations.");
  @example = prand(10,5);
  @example2 = prand(10,5);
  for (my $i=0; $i<=$#example; $i++)
    {
      my $r = $example[$i];
      my $r2 = $r+1+$example2[$i];
      $txt .= ShowLine(Op2(">",ShowUnary($r2),ShowUnary($r)));
      $txt .= ShowLine(TailOp1("not",Op2("=",ShowUnary($r2),ShowUnary($r))));
      $txt .= ShowLine(TailOp1("not",Op2("<",ShowUnary($r2),ShowUnary($r))));
    }

  return $txt;
};


ShowLesson(ShowNotLogicLesson());

