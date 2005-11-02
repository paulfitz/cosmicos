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

use identifiers;
use Math::BigInt;

my $txt = "";

my %id = %{GetIDs()};
my $free_id = GetFreeID();

my $out = "";

sub GenUnary {
  my $ct = shift;
  my $txt = "0";
  for (my $i=0; $i<$ct; $i++)
    {
      $txt .= "1";
#      $txt .= "(:)";
    }
  $txt .= "0";
  return $txt;
};

sub EvalString {
    my $str = shift;
    my $val = Math::BigInt->new(0);
    for (my $i=0; $i<length($str); $i++) {
	$val->bmul(256);
	$val->badd(ord(substr($str,$i,1)));
    }
    return $val->bstr();
}

while (<>)
  {
    chomp;
    $_ =~ s/U(1*)U/0${1}0/gi;
    if ($_ =~ /([^\#]*)((\#.*)?)/)
      {
	my $body = " $1 ";
	my $comment = $2;
	while ($body =~ /(\"([^\"]+)\")/) {
	    my $context = quotemeta($1);
	    my $str = $2;
	    my $val = EvalString($str);
	    $body =~ s/$context/$val/g;
	    print STDERR "\"$str\" -> $val\n";
#	    exit(1);
	}
	while ($body =~ /(([ \t\(\)])([a-zA-Z\!\?\+\*\-\_\>\<\=][a-zA-Z\!\?\+\*\-\/\_\>\<\=0-9]*)([ \t\(\)]))/)
	  {
	    my $context = $1;
	    my $left = $2;
	    my $term = $3;
	    my $right = $4;
	    my $unary = 0;
	    my $nterm = $term;
	    if ($term=~/(.*)-in-unary$/) {
		$nterm = $1;
		$unary = 1;
	    }
	    if (!defined($id{$nterm}))
	    {
		$id{$nterm} = $free_id;
		$free_id++;
	    }
	    my $num = $id{$nterm};
	    if ($unary) {
		$num = GenUnary($num);
	    }
	    $term = quotemeta($context);
	    $body =~ s/$term/$left$num$right/g;
	  }
	$body =~ s/^ //;
	$body =~ s/ $//;
	$body =~ s/\//-1/g;
	$out = $out . "$body$comment\n";
      }
  }

my $chop = 1;
my $comment = 0;
my $count = 0;
for (my $i=0; $i<length($out); $i++) {
    my $ch = substr($out,$i,1);
    if ($ch eq "#") {
	$comment = 1;
    }
    if ($ch eq "\n") {
	$comment = 0;
    }
    if (!$comment) {
	if ($ch eq "(") {
	    $count++;
	    if ($count==1) {
		$ch = "";
	    }
	}
	if ($ch eq ")") {
	    $count--;
	    if ($count==0) {
		$ch = "";
	    }
	}


#	if ($chop) {
#	    if ($ch eq "(") {
#		$ch = "";
#		$chop = 0;
#	    }
#	}
    }
    print $ch;
}

