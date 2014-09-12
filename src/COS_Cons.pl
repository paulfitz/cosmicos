#!/usr/bin/perl -w
use strict;

use cosmic;

sub ShowTheLesson {
  my $txt = "";
  $txt .= "# MATH illustrate pairs\n";

  $txt .= "define cons | ? x | ? y | ? z | z \$x \$y;\n";
  $txt .= "define car | ? cons:z | cons:z | ? x | ? y \$x;\n";
  $txt .= "define cdr | ? cons:z | cons:z | ? x | ? y \$y;\n";

  {
      my $idx = 0;
      my @examples = prand(10,10);
      for (my $i=0; $i<3; $i++) {
	  my $x1 = $examples[$idx];  $idx++;
	  my $x2 = $examples[$idx];  $idx++;
	  $txt .= "assign x (cons $x1 $x2) | = $x1 | car \$x;\n";
	  $txt .= "assign x (cons $x1 $x2) | = $x2 | cdr \$x;\n";
      }
  }
  {
      my $idx = 0;
      my @examples = prand(20,20);
      for (my $i=0; $i<3; $i++) {
	  my $x1 = $examples[$idx];  $idx++;
	  my $x2 = $examples[$idx];  $idx++;
	  my $x3 = $examples[$idx];  $idx++;
	  $txt .= "assign x (cons $x1 | cons $x2 $x3) | = $x1 | car \$x;\n";
	  $txt .= "assign x (cons $x1 | cons $x2 $x3) | = $x2 | car | cdr \$x;\n";
	  $txt .= "assign x (cons $x1 | cons $x2 $x3) | = $x3 | cdr | cdr \$x;\n";
      }
      {
	  my @examples = prand(5,5);
	  my @pre = @examples[0..($#examples-1)];
	  my $post = $examples[$#examples];
	  for (my $k=0; $k<=$#examples; $k++) {
	      $txt .= "assign x (cons " . join(" | cons ",@pre) . " $post) ";
	      $txt .= "| = $examples[$k]";
	      if ($k<$#examples) {
		  $txt .= " | car";
	      }
	      for (my $i=0; $i<$k; $i++) {
		  $txt .= " | cdr";
	      }
	      $txt .= " \$x;\n";
	  }
      }
  }

  return $txt;
}


ShowLesson(ShowTheLesson());

