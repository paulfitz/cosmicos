#!/usr/bin/perl -w

use strict;

use Tie::File;

my $java = $ARGV[1];
$java =~ s/\.class/\.java/;
tie my @target, 'Tie::File', $ARGV[0];
tie my @src, 'Tie::File', $java;

foreach my $t (@target) {
    if ($t =~ /\# CODE/) {
	foreach my $s (@src) {
	    print "# $s\n";
	}
    } else {
	print $t, "\n";
    }
}


