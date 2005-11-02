#!/usr/bin/perl -w

use strict;

my %table;

sub bin {
    my $val = shift;
    my $pre = shift;
    my $rem = shift;
    if ($rem==0) {
	$pre =~ s/^0+//;
	if ($pre eq "") {
	    $pre = "0";
	}
	my $key = "2${pre}3";
	my $let = "";
	if ($val>=16) {
	    $let = chr(ord('A')+$val-16);
	} else {
	    $let = chr(ord('a')+$val);
	}
	print STDERR "$key --> $let\n";
	$table{$key} = $let;
    } else {
	bin($val*2,$pre . "0",$rem-1);
	bin($val*2+1,$pre . "1",$rem-1);
    }
}

bin(0,"",5,0);

while (<>) {
    while ($_ =~ /(2(0|(1[01]{0,4}))3)/) {
	my $k = $1;
#	print STDERR "[$k]\n";
	my $v = $table{$k};
	if (defined($v)) {
	    $_ =~ s/$k/$v/g;
	}
    }
    print $_;
}

