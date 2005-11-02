#!/usr/bin/perl -w

use strict;

my $ok = 0;

my $target = $ARGV[0];

#print "(disk-restore \"$target.save\")\n";

while (<STDIN>) {
    if ($ok) {
	print $_;
    } else {
	if ($_ =~ /disk-save \"$target.save\"/) {
	    $ok = 1;
	}
    }
}

