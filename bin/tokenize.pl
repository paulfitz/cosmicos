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

#   Using a generator program for the message rather than writing the
#   message directly doesn't save much in size, but it sure makes things
#   easier to change afterwards -- at least small niggly things, larger
#   structural changes can be tricky.
#
#   This perl implementation is quite silly though and won't scale well.

use strict;

use Math::BigInt;

my %token;

# library of tokens (symbol sequences) used for designer's convenience.
# make sure names are uniquely decodable, or put in spaces!

$token{" "} = "";      # whitespace is ignored - no translation
$token{"\n"} = "";
$token{"\r"} = "";
$token{"\t"} = "";
$token{"."} = "0";     # digit zero
$token{":"} = "1";     # digit one
$token{"("} = "2";     # begin expression
$token{")"} = "3";     # end expression
$token{"/"} = "023";     # tail parentheses shorthand -- not strictly necessary
$token{";"} = "2233\n";   # end of line -- not strictly necessary


sub Tokens2Msg {
  my $msg = "";
  foreach my $t (@_)
    {
      if (!($t =~ /\[/))
	{
	  $msg .= $token{$t};
	}
    }
  return $msg;
};

my $first_high = 0;
my %translate_high;
my %translate_back;

sub Text2Tokens {
  my $txt = shift;
  my $base = 0;
  my @tokens = ();
  $txt =~ s/\#.*//g;
  #$txt =~ s/\[[^\]]*\]//g;
  while ($txt =~ /(\[([^\[\]]*)\])/)
    {
      my $x = $1;
      my $lst = $2;
      my $qx = quotemeta($x);
      my $paren = 0;
      my $term = 0;
      my $gap = 1;
      for (my $i=0; $i<length($lst); $i++)
	{
	  my $ch = substr($lst,$i,1);
	  if ($ch eq "(")
	    {
	      $paren++;
	      $gap = 0;
	    }
	  elsif ($ch eq ")")
	    {
	      $paren--;
	      $gap = 0;
	    }
	  elsif ($ch =~ /[ \t\n\r]/)
	    {
	      if ($paren==0)
		{
		  if (!$gap)
		    {
		      $term++;
		    }
		  $gap = 1;
		}
	    }
	  else
	    {
	      $gap = 0;
	    }
	  print "{$ch,$gap,$paren}\n";
	}
      if (!$gap)
	{
	  if ($paren==0)
	    {
	      $term++;
	    }
	}
      $txt =~ s/$qx/\(\(list $term\) $lst\)/;
    }
  print STDERR ">>> phase 1 complete \n";

  while ($txt =~ /([a-zA-Z_\+\*\=\>\<\?\^][a-zA-Z_\+\*\-\/\=\>\<\?\^\!0-9]*)/)
    {
      my $x = $1;
      my $qx = quotemeta($x);
      if (!defined($translate_high{$x}))
	{
	  $translate_high{$x} = "$first_high";
	  $translate_back{$first_high} = $x;
	  print "DEFINE [$x] as [$first_high]\n";
	  # this shouldn't happen any more - it was support
	  # for simple hand-written CosmicOS code
	  print STDERR "Problem, unexpected token [$x]\n";
	  exit(1);
	  $first_high++;
	}
      my $qy = $translate_high{$x};
      $txt =~ s/$qx/$qy/;
    }

  print STDERR ">>> phase 2 complete \n";

  if (0) {
      # this method became too slow, switched to something
      # faster below
      my $ct = 0;
      while ($txt =~ /([0-9]+)/)
      {
	  my $n = $1;
	  $ct++;
	  if ($ct%100==0) {
	      print STDERR "[$ct -> $n]\n";
	  }
	  if ($n =~ /^0(1*)0$/) {
	      my $n2 = $1;
	      $n2 =~ s/1/\:/g;
	      $txt =~ s/$n/.$n2./;
	  } else {
	      my $t = ShowBinaryVerbose($n);
	      $txt =~ s/$n/$t/;
	  }
      }
  } else {
      my $ref_txt = $txt . " ";
      $txt = "";
      my $num_txt = "";
      for (my $i=0; $i<length($ref_txt); $i++) {
	  my $ch = substr($ref_txt,$i,1);
	  if ($ch =~ /[0-9]/) {
	      $num_txt = $num_txt . $ch;
	  } else {
	      if (length($num_txt)>0) {
		  my $n = $num_txt;
		  if ($n =~ /^0(1*)0$/) {
		      my $n2 = $1;
		      $n2 =~ s/1/\:/g;
		      $txt = $txt . ".$n2.";
		  } else {
		      my $t = ShowBinaryVerbose($n);
		      $txt = $txt . $t;
		  }
		  $num_txt = "";
	      }
	      
	      $txt = $txt . $ch;
	  }
      }
      $txt =~ s/ $//;
  }

  print STDERR ">>> phase 3 complete \n";
  while ($txt =~ /(\{\^([^\}]*)\})/)
    {
      my $x = $1;
      my $qy = $2;
      my $qx = quotemeta($x);
      $txt =~ s/$qx/$qy/g;
#      print "$qx -> $qy\n";
#      die;
    }
  print STDERR ">>> phase 4 complete \n";
  my $line = 0;
  #print "MESSAGE before tokenizing is:\n$txt\n";
  for (my $i=0; $i<length($txt); $i++)
    {
      if (substr($txt,$i,1) eq "\n")
	{
	  $line++;
	  push(@tokens,"[$line]");
	}
      my $tok = substr($txt,$base,$i-$base+1);
      if (defined($token{$tok}))
	{
	  push(@tokens,$tok);
	  $base = $i+1;
	}
      elsif ($tok =~ /^\#.*\n/)
	{
	  $base = $i+1;
	}
    }
  print STDERR ">>> phase 5 complete \n";
  return @tokens;
};

sub EvalBinary {
  my $txt = shift;
  $txt =~ s/[^\.\:]//g;
  $txt =~ s/\:/1/g;
  $txt =~ s/\./0/g;
  $txt = "0b$txt";
  print "EVALUATE ", $txt, " AS ", oct($txt), "\n";
  return oct($txt);
};

sub Decompile {
  # decompile a message to make sure it is sane;
  my $txt = shift;
  my $src = "";
  
  my %detoken;

  foreach my $k (keys %token)
    {
      $detoken{$token{$k}} = $k;
    }
  $detoken{'4'} = ";\n";

  for (my $i=0; $i<length($txt); $i++)
    {
      my $ch = substr($txt,$i,1);
      if (defined($detoken{$ch}))
	{
	  $src .= $detoken{$ch};
	  print "token $ch -> $detoken{$ch}\n";
	}
    }

  while ($src =~ /(\(([\:\.]+)\))/)
    {
      my $all = $1;
      my $num = $2;
      my $q = quotemeta($all);
      my $n = EvalBinary($num);
      $src =~ s/$q/$n /g;
    }

  while ($src =~ /((\() *([0-9]+)) /)
    {
      my $all = $1;
      my $pre = $2;
      my $num = $3;
      my $q = quotemeta($all);
      my $n = $num;
      my $id = $translate_back{$n};
      if ($n>26)
	{
	  $src =~ s/$q /$pre${id}_$n /g;
        }
      else
	{
	  $src =~ s/$q /$pre${id} /g;
	}
    }

  $src =~ s/ +\)/\)/g;
  $src =~ s/\( +/\(/g;
  $src =~ s/  +/ /g;
  $src =~ s/\)([^ \;\n\)])/\) $1/g;

  return $src;
};


sub ShowBinary {
  my $txt = "";
  my $i = shift;
  $txt .= "[$i]";
  return $txt;
};


sub ShowBinaryVerbose {
  my $txt = "";
  my $n = Math::BigInt->new(shift);
#  $txt = sprintf("%b",$i);
  $txt = $n->as_bin();
  $txt =~ s/^0b//;
  $txt =~ s/0/\./g;
  $txt =~ s/1/\:/g;
  $txt = "($txt)";
  return $txt;
};




my $txt = "";
print STDERR "Starting...\n";
while (<>)
  {
      $_ =~ s/\-1/\//g;
      chomp;
      $txt .= "$_\n";
  }

print STDERR "Text2Tokens...\n";
my @inter = Text2Tokens($txt);
print STDERR "Tokens2Msg...\n";
my $msg = Tokens2Msg(@inter);

print "$msg\n";


