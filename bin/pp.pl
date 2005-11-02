#!/usr/bin/perl -w

use strict;

print "(load \"bin/ppf.scm\")\n";

while (<>)
  {
    chomp;
    $_ =~ s/\//\) \/ \(/g;
    if ($_ =~ /([^\#]*)((\#.*)?)/)
      {
	my $body = $1;
	my $comment = $2;
	my $lisp = $body;
#	while ($lisp =~ /(\(([\:\.]+)\))/)
#	  {
#	    my $all = $1;
#	    my $num = $2;
#	    my $val = EvalBinary($2);
#	    $all = quotemeta($all);
#	    $lisp =~ s/$all/ $val /g;
#	  }
	$lisp =~ s/\:/ppcc/g;
	$lisp =~ s/\./ppcd/g;
#	$lisp =~ s/lambda/lambda/g;
#	$lisp =~ s/\?/ lambda /g;
	$lisp =~ s/\;//g;
	if ($lisp =~ /[^ \t]/)
	  {
	    if (!($lisp =~ /unary/))
	      {
		$lisp = "(pretty-print-fritz '($lisp))";
	      }
	    else
	      {
		$lisp = "(pp '($lisp))";
	      }
	    $lisp = "(begin $lisp (display \"\;\\n\"))";
	    #$lisp = "(fritz-eval-show '$lisp)";
	  }
#	$comment =~ s/^\#/\;/;
	if ($comment =~ /\#/)
	  {
	    $comment = "(begin (display \"$comment\") (display \"\\n\"))\n";
	  }
	print "$lisp$comment\n";
      }

  }

print "(begin (display \"STOPIT\") (display \"\\n\"))\n";
