#!/usr/bin/perl -w

use strict;

my $msg = "";
while (<>) {
  $msg = $msg . $_;
}

$msg =~ s/\n//g;
$msg =~ s/([a-z0-9]{80})/$1\n/g;
print "$msg\n";
