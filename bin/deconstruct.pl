#!/usr/bin/perl -w

#   Author: Paul Fitzpatrick, paulfitz@ai.mit.edu
#   Copyright (c) 2003 Paul Fitzpatrick
#
#   This file is part of CosmicOS.
#
#   CosmicOS is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   CosmicOS is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with CosmicOS; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

use strict;
use Math::BigInt;

sub EvalBinary {
  my $txt = shift;
  $txt =~ s/[^\.\:]//g;
  $txt =~ s/\:/1/g;
  $txt =~ s/\./0/g;
  $txt =~ s/\//-1/g;
  $txt = "0b$txt";
  #print "EVALUATE ", $txt, " AS ", oct($txt), "\n";
  #return oct($txt);
  my $x = Math::BigInt->new($txt);
  return $x->bstr();
};


my $txt = "";

my @primer = ();

my $id = 0;

while (<>) {
    chomp;
    $txt = $txt . $_;
    if ($txt =~ /\;/ || $txt =~ /\#/) {
	$_ = $txt;
	$txt = "";
	if ($_ =~ /([^\#]*)((\#.*)?)/) {
	    my $body = $1;
	    my $comment = $2;
	    my $lisp = $body;
	    while ($lisp =~ /(\(([\:\.]+)\))/) {
		my $all = $1;
		my $num = $2;
		my $val = EvalBinary($2);
		$all = quotemeta($all);
		$lisp =~ s/$all/ $val /g;
	    }
	    #$lisp =~ s/\(\:\)/ 1 /g;
	    #$lisp =~ s/\(\.\)/ 0 /g;
	    $lisp =~ s/\;//g;
	    if ($lisp =~ /[^ \t]/) {
		$lisp = "($lisp)";
		while ($lisp =~ /(([^0-9])0(1*)0([^0-9]))/) {
		    my $all = quotemeta($1);
		    my $pre = $2;
		    my $ct = length($3);
		    my $post = $4;
		    $lisp =~ s/$all/$pre$ct$post/g;
		}
		push(@primer,$lisp);
	    }
	    if ($lisp =~ /\((.*)\)/) {
		my $line = "$1;";
		# fix up white space
		$line =~ s/([\-0-9]+)/ $1 /g;
		$line =~ s/\t/ /g;
		$line =~ s/(.*)\;.*/\($1\)\;/;
		$line =~ s/\)/\) /g;
		$line =~ s/ +\)/\)/g;
		$line =~ s/\( +/\(/g;
		$line =~ s/  +/ /g;
		$line =~ s/ +\;/\;/g;
		print "$line\n";
	    }
	}
    }
    $id++;
}

