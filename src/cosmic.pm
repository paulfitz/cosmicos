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
$token{";"} = "4\n";   # end of line -- not strictly necessary

sub irand {
  my $lim = shift;
  my $result = int(rand($lim));
  return $result;
};

sub prand {
  my $top = shift;
  my $crop = $top;
  if ($#_>=0)
    {
      $crop = shift;
    }
  my @lst = (0 .. ($top-1));
  my @lst_out = ();
  for (my $i=$top; $i>0; $i--)
    {
      my $sel = irand($i);
      push(@lst_out,$lst[$sel]);
      if ($sel<$i-1)
	{
	  $lst[$sel] = $lst[$i-1];
	}
    }
  if ($crop<$top)
    {
      @lst_out = @lst_out[0 .. ($crop-1)];
    }
  return @lst_out;
};


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
	  #print "{$ch,$gap,$paren}\n";
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
  #print ">>> $txt \n";

  while ($txt =~ /([a-zA-Z_\+\*\-\/\=\>\<\?\^][a-zA-Z_\+\*\-\/\=\>\<\?\^\!0-9]*)/)
    {
      my $x = $1;
      my $qx = quotemeta($x);
      if (!defined($translate_high{$x}))
	{
	  $translate_high{$x} = "$first_high";
	  $translate_back{$first_high} = $x;
	  #print "DEFINE [$x] as [$first_high]\n";
	  $first_high++;
	}
      my $qy = $translate_high{$x};
      $txt =~ s/$qx/$qy/;
    }
  while ($txt =~ /([0-9]+)/)
    {
      my $n = $1;
      my $t = ShowBinaryVerbose($n);
      $txt =~ s/$n/$t/;
    }
  while ($txt =~ /(\{\^([^\}]*)\})/)
    {
      my $x = $1;
      my $qy = $2;
      my $qx = quotemeta($x);
      $txt =~ s/$qx/$qy/g;
#      print "$qx -> $qy\n";
#      die;
    }
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
  return @tokens;
};

sub EvalBinary {
  my $txt = shift;
  $txt =~ s/[^\.\:]//g;
  $txt =~ s/\:/1/g;
  $txt =~ s/\./0/g;
  $txt = "0b$txt";
  #print "EVALUATE ", $txt, " AS ", oct($txt), "\n";
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
	  #print "token $ch -> $detoken{$ch}\n";
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


sub ShowOldUnary {
  my $ct = shift;
  my $txt = "";
  for (my $i=0; $i<$ct; $i++)
    {
      $txt .= "1 ";
#      $txt .= "(:)";
    }
  $txt .= "0";  # necessary for unary to be a well-defined function
#  $txt .= "(.)";  # necessary for unary to be a well-defined function
  if ($txt ne "")
    {
      $txt = Paren("unary", $txt);
    }
  else
    {
      $txt = Paren("unary");
    }
  return $txt;
};


sub ShowOld2Unary {
  my $ct = shift;
  my $txt = "U";
  for (my $i=0; $i<$ct; $i++)
    {
      $txt .= "1";
#      $txt .= "(:)";
    }
  $txt .= "U";
  return $txt;
};

sub ShowUnary {
  my $ct = shift;
  my $txt = "(unary ";
  for (my $i=0; $i<$ct; $i++)
    {
      $txt .= " 1";
    }
  $txt .= " 0)";
  return $txt;
};


sub ShowBinary {
  my $txt = "";
  my $i = shift;
  $txt .= "[$i]";
  return $txt;
};


sub ShowBinaryVerbose {
  my $txt = "";
  my $i = shift;
  $txt = sprintf("%b",$i);
  $txt =~ s/0/\./g;
  $txt =~ s/1/\:/g;
  $txt = "($txt)";
  return $txt;
};

sub ShowTerm {
  return join(" ",@_);
};

sub Paren {
  return "(" . ShowTerm(@_) . ")";
};

sub ShowLine {
  return ShowTerm(@_) . ";\n";
};


sub Op1 {
  if (!($#_==1)) { die "broken Op1 " . join(" ", @_) . "\n"; }
  my $cmp = shift;
  my $o1 = shift;
  return TailOp1($cmp, $o1);
};

sub TailOp1 {
  if (!($#_==1)) { die "broken Op1 " . join(" ", @_) . "\n"; }
  my $cmp = shift;
  my $o1 = shift;
  return TailOp($cmp, $o1);
};

sub BareOp1 {
  my $cmp = shift;
  my $o1 = shift;
  return "$cmp$o1";
};

sub Op2 {
  if (!($#_==2)) { die "broken Op2 " . join(" ", @_) . "\n"; }
  if ($_[0] eq "define" || $_[0] eq "lettt") {
      return TailOp2(@_);
  }
  my $cmp = shift;
  my $o1 = shift;
  my $o2 = shift;
  return Paren($cmp, $o1, $o2);
};

sub Op {
  if ($_[0] eq "define" || $_[0] eq "lettt") {
      return TailOp2(@_);
  }
  return Paren(@_);
};

sub Mogrify {
    my $str = shift;
    if ($str =~ /\(/) {
	$str =~ s/^\(//;
	$str =~ s/\)$//;
	return "| $str";
    }
    return $str;
}

sub TailOp2 {
  if (!($#_==2)) { die "broken Op2 " . join(" ", @_) . "\n"; }
  my $cmp = shift;
  my $o1 = shift;
  my $o2 = shift;
  return Paren($cmp, "$o1 " . Mogrify($o2));
};


sub TailOp {
    my $x = shift;
    my $y = shift;
    return "($x " . Mogrify($y) . ")";
}


sub Lit {
  my $x = shift;
  return $x;
};

sub Ref {
  my $x = shift;
  return "\$" . $x;
};

sub Tag {
  my $x = shift;
  return "{$x}";
};

sub Num {
  my $x = shift;
  return "$x";
};

sub Proc {
#  return Paren("?", @_);
    my $arg = shift;
    my $val = shift;
    return "(? $arg " . Mogrify($val) . ")";
};

sub ProcMultiple {
  my $plist = shift;
  my @args = @$plist;
  my $txt = "";
  return Paren("lambda", Paren(@args), @_);
};

sub Template {
  my $plist = shift;
  my @args = @$plist;
  my $txt = "";
  return Paren("template", Paren(@args), @_);
};

sub ProcTyped {
  my $plist = shift;
  my @args = @$plist;
  my $txt = "";
  for (my $i=0; $i<=$#args; $i++)
    {
      if ($i%2==1)
	{
	  if ($i>1)
	    {
	      $txt .= " ";
	    }
	  $txt .= "($args[$i-1] $args[$i])";
	}
    }
  return Paren("lambda", Paren($txt), @_);
};

sub Let {
  my $plist = shift;
  my @args = @$plist;
  my $txt = "";
  for (my $i=0; $i<=$#args; $i++)
    {
      if ($i%2==1)
	{
	  if ($i>1)
	    {
	      $txt .= " ";
	    }
	  $txt .= "($args[$i-1] $args[$i])";
	}
    }
  return Paren("let", Paren($txt), @_);
};

sub Apply {
  return Paren(@_);
};



sub ShowTrue {
  return "\$true";
};

sub ShowFalse {
  return "\$false";
};

sub ShowTrueComparisonOld {
  my $txt = "";
  my $c = irand(3);
  if ($c==0)
    {
      my $r = irand(6);
      $txt .= Op2("=",ShowUnary($r),ShowUnary($r));
    }
  elsif ($c==1)
    {
      my $r = irand(6);
      my $r2 = $r+1+irand(3);
      $txt .= Op2("<",ShowUnary($r),ShowUnary($r2));
    }
  else
    {
      my $r = irand(6);
      my $r2 = $r+1+irand(3);
      $txt .= Op2(">",ShowUnary($r2),ShowUnary($r));
    }

  return $txt;
}



sub ShowFalseComparisonOld {
  my $txt = "";
  my $c = irand(3);
  if ($c==0)
    {
      my $r = irand(6);
      my $r2 = irand(6);
      if ($r == $r2)
	{
	  if(irand(2)==1)
	    {
	      $r++;
	    }
	  else
	    {
	      $r2++;
	    }
	}
      $txt .= Op2("=",ShowUnary($r),ShowUnary($r2));
    }
  else
    {
      my $r = irand(7);
      my $r2 = irand(7);
      my $cmp = ">";
      if ($r>$r2)
	{
	  $cmp = "<";
	}
      else
	{
	  $cmp = ">";
	}
      $txt .= Op2($cmp,ShowUnary($r),ShowUnary($r2));      
    }

  return $txt;
}


sub ShowTrueComparisonBin {
  my $txt = "";
  my $c = irand(3);
  if ($c==0)
    {
      my $r = irand(6);
      $txt .= Op2("=",($r),($r));
    }
  elsif ($c==1)
    {
      my $r = irand(6);
      my $r2 = $r+1+irand(3);
      $txt .= Op2("<",($r),($r2));
    }
  else
    {
      my $r = irand(6);
      my $r2 = $r+1+irand(3);
      $txt .= Op2(">",($r2),($r));
    }

  return $txt;
}

sub ShowTrueComparison {
    return ShowTrueComparisonBin();
}


sub ShowFalseComparisonBin {
  my $txt = "";
  my $c = irand(3);
  if ($c==0)
    {
      my $r = irand(6);
      my $r2 = irand(6);
      if ($r == $r2)
	{
	  if(irand(2)==1)
	    {
	      $r++;
	    }
	  else
	    {
	      $r2++;
	    }
	}
      $txt .= Op2("=",($r),($r2));
    }
  else
    {
      my $r = irand(7);
      my $r2 = irand(7);
      my $cmp = ">";
      if ($r>$r2)
	{
	  $cmp = "<";
	}
      else
	{
	  $cmp = ">";
	}
      $txt .= Op2($cmp,($r),($r2));      
    }

  return $txt;
}

sub ShowFalseComparison {
    return ShowFalseComparisonBin();
}


sub ShowListVerbose {
  my $txt = "";
  $txt .= Op(Op("list", ($#_+1)), @_);
  return $txt;
};

sub ShowListOld {
  my $txt = "";
  $txt .= "[" . join(" ",@_) . "]";
  return $txt;
};

sub ShowList {
  my $txt = "";
  $txt .= "(" . join(" ",("vector", @_)) . ")";
  return $txt;
};

sub ShowLesson {
    my $ltxt = shift;

    my $txt = "";

    $txt = $ltxt;
    # replace old "/" separator with new "|"
    # we assume .pl lessons will die out before "/" gets reused
    $txt =~ s/ \/ / \| /g;
    
    print $txt;
}

# use consistent random choices
# (really not acceptable to use random numbers, should use
# look-up tables on a per lesson basis, to ensure stability
# of sequences within lessons)

srand(1);

1;

