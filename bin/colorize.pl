#!/usr/bin/perl -w

use strict;


my $txt = "";

while (<>) {
    $txt .= $_;
}
$txt =~ s/\&nbsp\;/\~/g;

my $prev_color = "#ffffff";
my $colored = 0;

sub emit {
    my $ch = shift;
    my $color = shift;
    my $close = 0;
    my $open = 0;
#    print STDERR $ch, " --> [", $color, "]\n";
    if (!($ch=~/[ \t\n\r]/)) {
	if (!$colored) {
	    $open = 1;
	    $close = 1;
	}
    }
    if ($color ne $prev_color) {
	$close = 1;
	$open = 1;
    }
    if ($ch eq "\n" || $ch eq "\r") {
	$close = 1;
	$open = 0;
    }
    if ($close) {
	if ($colored) {
	    print "</font>";
	    $prev_color = "#ffffff";
	}
	$colored = 0;
    }
    if ($open) {
	if ($color ne "#ffffff") {
	    print "<font style='background-color: $color'>";
	    $colored = 1;
	}
    }
    $prev_color = $color;
    print $ch;
}

my $r = 255;
my $g = 255;
my $b = 255;
my $level = 0;
my $step = 50;
my $ct = 0;
my @pr = ();
my @pg = ();
my @pb = ();
my @plev = ();
my @pcurr = ();
my $lev = 0;
srand(1);
my $current = "#ffffff";
my $blank = 0;
for (my $i=0; $i<=length($txt); $i++) {
    my $ch = substr($txt,$i,1);
    my $done = 0;
    if ($ch eq "~") {
	if ($blank==0) {
	    #print "<FONT STYLE='background-color: #ffffff'>";
	    $blank=1;
	}
	print "&nbsp;";
	$done = 1;
    } else {
	if ($blank) {
	    #print "</FONT>";
	    $blank = 0;
	}
    }
    if (!$done) {
	if ($ch eq "(") {
	    
	    push(@pr,$r);
	    push(@pg,$g);
	    push(@pb,$b);
	    push(@plev,$lev);
	    push(@pcurr,$current);
	    
	    my $v = 255-$ct*$step;
	    if ($v<0) { $v = 0; }
	    my $sel = $lev%3; #irand(3);
	    if ($ct>0) {
		if ($sel==0) {
		    $r -= $step;
		} elsif ($sel==1) {
		    $g -= $step;
		} elsif ($sel==2) {
		    $b -= $step;
		}
	    }
	    if ($r<0) { $r = 0; }
	    if ($g<0) { $g = 0; }
	    if ($b<0) { $b = 0; }
	    my $th = 150;
	    if ($r<$th&&$g<$th&&$b<$th) {
		$r = $th;
		$g = $th;
		$b = $th;
	    }
	    my $color = sprintf("#%02x%02x%02x",$r,$g,$b);
	    
	    #$current = "<FONT STYLE='background-color: $color'>";
	    #print "$current(";
	    $current = $color;
	    emit("(",$color);
	    $ct++;
	} elsif ($ch eq ")") {
	    if ($ct>0) {
		$lev = pop(@plev);
		$r = pop(@pr);
		$g = pop(@pg);
		$b = pop(@pb);
		emit(")",$current);
		$current = pop(@pcurr);
		$ct--;
		if ($ct>0) {
		    $lev = ($lev+1)%3;
		}
	    }
	} else {
	    if ($ch=~/\n/) {
		srand(1);
		if ($current ne "") {
		    $blank = 2;
		}
	    }
	    emit("$ch",$current);
	}
    }
}
