#!/usr/bin/perl -w

use strict;

my $msg_file = $ARGV[0];
my $patch_file = $ARGV[1];

open(PATCH,"<$patch_file") || die "could not open $patch_file";

my %pres;
my %posts;
while(<PATCH>) {
    chomp($_);
    if ($_ =~ /^DEMO.*line +([0-9]+).* from \((.*)\) to \((.*)\)/) {
	my $id = $1;
	my $pre = $2;
	my $post = $3;
	$pres{$id} = $pre;
	$posts{$id} = $post;
    }
}

open(MSG,"<$msg_file") || die "could not open $msg_file";

my $id = 0;
my $last_id = 0;
while(<MSG>) {
    if (defined($posts{$id})) {
	chomp($_);
	if ($_ eq "$pres{$id};") {
	    print "$posts{$id};\n";
	} else {
	    print STDERR "FAILED to patch line $id from $msg_file:\n";
	    print STDERR "  Expected [$pres{$id};]\n";
	    print STDERR "  Got      [$_]\n";
	    exit(1);
	}
    } else {
	print $_;
    }
    $last_id = $id;
    $id++;
}

my $failed = 0;
foreach my $id (keys %pres) {
    if ($id>$last_id) {
	print STDERR "FAILED to patch line $id from $msg_file:\n";
	print STDERR "  Expected [$pres{$id};]\n";
	print STDERR "  Only reached line $last_id\n";
	$failed = 1;
    }
}
if ($failed) {
    exit(1);
}
