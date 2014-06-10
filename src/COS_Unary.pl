#!/usr/bin/perl -w
use strict;

use cosmic;

sub EarlyExample {
    my $txt = shift;
    return ShowLine("(intro-in-unary $txt)");
}

sub ShowUnaryLesson {
  my $txt = "";

  $txt .= "# MATH introduce numbers (in unary notation)\n";
  $txt .= "# Here we count up from zero, go through some primes, etc.\n";
  $txt .= "# There is some syntax around the numbers, but that doesn't\n";
  $txt .= "# need to be understood at this point.\n";
  $txt .= "# Any 'words' written here are converted to arbitrary integers\n";
  $txt .= "# in the actual message.  Any word ending in -in-unary will be given\n";
  $txt .= "# in unary rather than the binary code used in the main body\n";
  $txt .= "# of the message.\n";
  for (my $i=0; $i<=16; $i++)
    {
	$txt .= EarlyExample(ShowUnary($i));
    }
  
#  for (my $i=26; $i>=1; $i--)
#    {
#	$txt .= EarlyExample(ShowUnary($i));
#    }

  foreach my $i (2, 3, 5, 7, 11, 13)
    {
	$txt .= EarlyExample(ShowUnary($i));
    }

  foreach my $i (1, 4, 9, 16)
    {
	$txt .= EarlyExample(ShowUnary($i));
    }

#  foreach my $i (1, 8, 27)
#    {
#	$txt .= EarlyExample(ShowUnary($i));
#    }


  $txt .= "# MATH introduce equality for unary numbers\n";
  $txt .= "# The intro operator does nothing essential, and could be\n";
  $txt .= "# omitted - it just tags the first use of a new operator.\n";
  $txt .= "# The = operator is introduced alongside a duplication of\n";
  $txt .= "# unary numbers.  The meaning will not quite by nailed down\n";
  $txt .= "# until we see other relational operators.\n";

  my @examples = (1, 2, 3, 4, 5, 6, 7, 8, 1, 6, 2);
  my @examples2 = ();
  for (my $i=0; $i<=$#examples; $i++)
  {
      my $r = $examples[$i];
      $txt .= ShowLine(Op2("=-in-unary",ShowUnary($r),ShowUnary($r)));
  }

  $txt .= "# MATH now introduce other relational operators\n";
  $txt .= "# After this lesson, it should be clear what contexts\n";
  $txt .= "# < > and = are appropriate in.\n";

#  $txt .= ShowLine(Op("intro",">"));
  $txt .= "# drive the lesson home\n";
  for (my $i=1; $i<=4; $i++) {
      for (my $j=1; $j<=4; $j++) {
	  my $r = $j;
	  my $r2 = $i;
	  my $cmp = "=-in-unary";
	  if ($r>$r2)
	  {
	      $cmp = ">-in-unary";
	  }
	  elsif ($r<$r2)
	  {
	      $cmp = "<-in-unary";
	  }
	  $txt .= ShowLine(Op2($cmp,ShowUnary($r),ShowUnary($r2)));
      }
  }
  for (my $i=0; $i<=10; $i++)
    {
      my $r = irand(10);
      my $r2 = irand($r);
      $txt .= ShowLine(Op2(">-in-unary",ShowUnary($r+1),ShowUnary($r2)));
    }
#  $txt .= ShowLine(Op("intro","<"));
  for (my $i=0; $i<=10; $i++)
    {
      my $r = irand(10);
      my $r2 = irand($r);
      $txt .= ShowLine(Op2("<-in-unary",ShowUnary($r2),ShowUnary($r+1)));
    }
  $txt .= "# switch to binary labelling for commands\n";
  for (my $i=1; $i<=4; $i++) {
      for (my $j=1; $j<=4; $j++) {
	  my $r = $j;
	  my $r2 = $i;
	  my $cmp = "=";
	  if ($r>$r2)
	  {
	      $cmp = ">";
	  }
	  elsif ($r<$r2)
	  {
	      $cmp = "<";
	  }
	  $txt .= ShowLine(Op2($cmp,ShowUnary($r),ShowUnary($r2)));
      }
  }
  $txt .= "# a few more random examples\n";
  for (my $i=0; $i<=10; $i++)
    {
      my $r = irand(6);
      my $r2 = irand(6);
      my $cmp = "=";
      if ($r>$r2)
	{
	  $cmp = ">";
	}
      elsif ($r<$r2)
	{
	  $cmp = "<";
	}
      $txt .= ShowLine(Op2($cmp,ShowUnary($r),ShowUnary($r2)));
    }

  return $txt;
};


ShowLesson(ShowUnaryLesson());

