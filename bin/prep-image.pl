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

use POSIX;

my $txt = "";
while(<>)
  {
    chomp;
    $txt .= $_;
  }

$txt =~ s/([0-9])([0-9])/$1 $2/g;
$txt =~ s/([0-9])([0-9])/$1 $2/g;

my @lst = split(/ /,$txt);
my @olst = @lst;
#foreach my $item (@lst)
#  {
#    push (@olst,($item)*55);
#  }

my $d = ceil(sqrt($#olst+1));

my @pic;

#$d = 3;

my $x = 0;
my $y = 0;
my $o = 0;
for (my $c=0; $c<$d*$d; $c++)
  {
#    my $x = $c%$d;
#    my $y = floor($c/$d);
    $pic[$x][$y] = 6;
    if ($c<=$#olst)
      {
	$pic[$x][$y] = $olst[$c];
      }
    $x = $x-1;
    $y = $y+1;
    if ($o<$d-1)
      {
	if ($x<0)
	  {
	    $o++;
	    $x = $o;
	    $y = 0;
#	    print "$x $y $d\n";
	  }
      }
    else
      {
	if ($y>=$d)
	  {
	    $o++;
	    $y = $o+1-$d;
	    $x = $d-1;
#	    print "+ $x $y $d\n";
	  }
      }
  }

#$d = -1;
#print "P2\n";
#print "# view.pgm\n";
print "P3\n";
print "# view.ppm\n";
print "$d $d\n";
print "255\n";
my @rr = (0,   210, 0,    64,  128, 255, 0);
my @gg = (210,   0, 0,    64,  128, 255, 0);
my @bb = (0,     0, 128, 128,    0, 255, 0);
for (my $c=0; $c<$d*$d; $c++)
  {
    my $x = $c%$d;
    my $y = floor($c/$d);
    if ($x>0)
      {
	print " ";
      }
    my $v = $pic[$x][$y];
    print "$rr[$v] $gg[$v] $bb[$v]\n";
    if ($x==$d-1)
      {
	print "\n";
      }
  }

