#!/usr/bin/perl -w

use strict;

my $s = 6;
my $s2 = 8;

my %arr;

my @line = ();

while (<>) {
    if ($_ =~ /^([\-0-9]+) ([\-0-9]+) ([\-0-9]+) ([\-0-9]+)( ([\-0-9]+))?/) {
	my $xmid = $1;
	my $ymid = $2;
	my $dx = $4;
	my $dy = $3;
	my $v = $6 || 0;
	chomp($_);
	push(@line,$_);
	if ($v) {
	    #$p->setcolour(255,0,0);
	}
	for (my $i=-$s+1; $i<$s; $i++) {
	    my $x = ($xmid*$s2+$dy*$i);
	    my $y = ($ymid*$s2+$dx*$i);
	    $arr{"$x $y"} = 1;
	}
	if ($v) {
	    for (my $i=-$s+1; $i<$s-1; $i++) {
		my $x = ($xmid*$s2+$dy*$i+$dx);
		my $y = ($ymid*$s2+$dx*$i-$dy);
		$arr{"$x $y"} = 1;
		my $x2 = ($xmid*$s2+$dy*$i-$dx);
		my $y2 = ($ymid*$s2+$dx*$i+$dy);
		$arr{"$x2 $y2"} = 1;
	    }
	}
	for (my $i=0; $i<3; $i++) {
	    for (my $j=-$i; $j<=$i; $j++) {
		my $x = ($xmid*$s2+$dy*($s-$i)-$dx*$j);
		my $y = ($ymid*$s2+$dx*($s-$i)+$dy*$j);
		$arr{"$x $y"} = 1;
	    }
		#my $x2 = ($xmid*$s2+$dy*($s-$i)+$dx*$i);
		#my $y2 = ($ymid*$s2+$dx*($s-$i)-$dy*$i);
		#$arr{"$x2 $y2"} = 1;
	}
	my $xon = ($dx)*0.2;
	my $yon = ($dy)*0.2;
	my $xoff = $yon;
	my $yoff = $xon;
	if ($v) {
	    #$p->setcolour(0,0,0);
	}
    }
}


my $xmin = 100000;
my $ymin = 100000;
my $xmax = 0;
my $ymax = 0;

foreach my $key (keys %arr) {
    if ($key =~ /([0-9]+) ([0-9]+)/) {
	my $x = $1;
	my $y = $2;
	if ($x>$xmax) { $xmax = $x; }
	if ($y>$ymax) { $ymax = $y; }
	if ($x<$xmin) { $xmin = $x; }
	if ($y<$ymin) { $ymin = $y; }
    }
}

my $d1 = $ymax+$ymin+8;
my $d2 = $xmax+$xmin+8;

for (my $y=0; $y<$d1; $y++) {
    $arr{"0 $y"} = 1;
    $arr{($d2-1) . " $y"} = 1;
}
for (my $x=0; $x<$d2; $x++) {
    $arr{"$x 0"} = 1;
    $arr{"$x " . ($d1-1)} = 1;
}

print "# GATE testing alternate primer based on gates: CIRCUIT_NAME circuit\n";
print "# This section contains one or more representations of a circuit\n";
print "# constructed using UNLESS gates.\n";

print "(define CIRCUIT_NAME_gate | vector ";

@line = sort {
    (my $a1, my $a2, my $a3, my $a4, my @rema) = split(/ /,$a);
    (my $b1, my $b2, my $b3, my $b4, my @remb) = split(/ /,$b);
#    $a1 -= $a3;  $a2 -= $a4;
#    $b1 -= $b3;  $b2 -= $b4;
    my $v = ($a1 <=> $b1);
    if ($v!=0) { return $v; }
    return ($a2 <=> $b2);
} @line;

foreach my $l (@line) {
    if ($l =~ /^([\-0-9]+) ([\-0-9]+) ([\-0-9]+) ([\-0-9]+)( ([\-0-9]+))?/) {
	my $xmid = $1;
	my $ymid = $2;
	my $dx = $3;
	my $dy = $4;
	my $v = $6 || 0;
	my $x1 = $xmid-$dx;
	my $y1 = $ymid-$dy;
	my $x2 = $xmid+$dx;
	my $y2 = $ymid+$dy;
	my $v2 = $v?"\$true":"\$false";
	print "\n  (vector $x1 $y1 $x2 $y2 $v2)";
    }
}
print ");\n";

print "(define CIRCUIT_NAME_image | make-image $d1 $d2 | vector ";
for (my $y=0; $y<$d1; $y++) {
    print "\n  (";
    for (my $x=0; $x<$d2; $x++) {
	my $v = 0;
	if (defined($arr{"$x $y"})) {
	    $v = 1;
	}
#	if ($x>0) { print " "; }
	my $txt = ":";
	if (!$v) {
	    $txt = ".";
	}
	print $txt;
    }
    print ")";
}
print ");\n";


print "(equal \$CIRCUIT_NAME_gate | distill-circuit \$CIRCUIT_NAME_image);\n";

#print "(distill-circuit (CIRCUIT_NAME_image));\n";
