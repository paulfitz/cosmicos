#!/usr/bin/perl -w

use strict;

my $txt = "";

while (<>) {
    $txt .= $_;
}

$txt =~ s/\) \/ \(/ \| /g;
$txt =~ s/\)[\n\r \t]*\/ *[\n\r]+([ \t]*)\(/ \|\n$1 /g;
$txt =~ s/\|/\//g;

print $txt;
