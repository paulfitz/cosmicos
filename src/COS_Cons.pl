#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowTheLesson {
  my $txt = "";
  $txt .= "# MATH illustrate pairs\n";

  $txt .= "(define cons (? x / ? y / ? f / f (x) (y)));\n";
  $txt .= "(define car (? pair / pair (? x / ? y / x)));\n";
  $txt .= "(define cdr (? pair / pair (? x / ? y / y)));\n";

  {
      my $idx = 0;
      my @examples = prand(10,10);
      for (my $i=0; $i<3; $i++) {
	  my $x1 = $examples[$idx];  $idx++;
	  my $x2 = $examples[$idx];  $idx++;
	  $txt .= "(assign x (cons $x1 $x2) / = (car / x) $x1);\n";
	  $txt .= "(assign x (cons $x1 $x2) / = (cdr / x) $x2);\n";
      }
  }
  {
      my $idx = 0;
      my @examples = prand(20,20);
      for (my $i=0; $i<3; $i++) {
	  my $x1 = $examples[$idx];  $idx++;
	  my $x2 = $examples[$idx];  $idx++;
	  my $x3 = $examples[$idx];  $idx++;
	  $txt .= "(assign x (cons $x1 / cons $x2 $x3) / = (car / x) $x1);\n";
	  $txt .= "(assign x (cons $x1 / cons $x2 $x3) / = (car / cdr / x) $x2);\n";
	  $txt .= "(assign x (cons $x1 / cons $x2 $x3) / = (cdr / cdr / x) $x3);\n";
      }
      {
	  my @examples = prand(5,5);
	  my @pre = @examples[0..($#examples-1)];
	  my $post = $examples[$#examples];
	  $txt .= "(assign x (cons " . join(" / cons ",@pre) . " $post) ";
	  for (my $k=0; $k<$#examples; $k++) {
	      $txt .= "/ and (= $pre[$k] / car / ";
	      for (my $i=0; $i<$k; $i++) {
		  $txt .= "cdr / ";
	      }
	      $txt .= "x) ";
	  }
	  $txt .= "(= $post / ";
	  for (my $i=0; $i<$#examples; $i++) {
	      $txt .= "cdr / ";
	  }
	  $txt .= "x));\n";
      }
  }

  return $txt;
}


ShowLesson(ShowTheLesson());

