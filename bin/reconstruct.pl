#!/usr/bin/perl -w

use strict;
use Math::BigInt;


sub EvalBinary {
  my $txt = shift;
  $txt = "0b$txt";
  my $x = Math::BigInt->new($txt);
  return $x->bstr();
};

my $state = "";
my $open = 0;
my $output = "";

sub Apply {
    my $sym = shift;
    if ($state ne "") {
	if ($sym ne "0" && $sym ne "1") {
	    $output .= " " . EvalBinary($state) . " ";
	    $state = "";
	    $open = 0;
	    if ($sym ne ")") {
		die "UNEXPECTED [$sym]";
	    } else {
		$sym = "";
	    }
	}
    }
    if ($sym eq "(") {
	if ($open) { $output .= $sym; }
	else {
	    $open = 1;
	}
    } elsif ($sym eq "0" || $sym eq "1") {
	$state .= $sym;
#	print "[$state:$sym]";
	if ($state =~ /^0(1*)0$/) {
	    my $n = $1;
	    $output .= " " . length($n) . " ";
	    $state = "";
	}
    } else {
	if ($open) {
	    $output .= "(";
	    $open = 0;
	}
	$output .= $sym;
    }
}


my $txt = "";
while (<>) {
    chomp($_);
    $txt .= $_;
}

$txt =~ s/2233/\;\n/g;
$txt =~ s/023/ \/ /g;
$txt =~ s/2/\(/g;
$txt =~ s/3/\)/g;

for (my $i=0; $i<length($txt); $i++) {
    Apply(substr($txt,$i,1));
}

foreach my $line (split(/\n/,$output)) {
    # fix up white space
    $line =~ s/(.*)\;.*/\($1\)\;/;
    $line =~ s/\)/\) /g;
    $line =~ s/ +\)/\)/g;
    $line =~ s/\( +/\(/g;
    $line =~ s/  +/ /g;
    $line =~ s/ +\;/\;/g;

    # deal with / construct
    $line =~ s/\//\-1/g;

    print "$line\n";
}

