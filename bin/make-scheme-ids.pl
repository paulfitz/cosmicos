#!/usr/bin/perl -w

use strict;

use identifiers;

my %id = %{GetIDs()};

print "(define fritz-name\n";
print "   (lambda (id)\n";
print "      (case id\n";
foreach my $key (sort { $id{$a} <=> $id{$b} } (keys(%id))) {
    print "            (($id{$key}) \"$key\")\n";
}
print "            (else (number->string id))\n";
print "      )))\n";
