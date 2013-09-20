#!/usr/bin/perl -w

use strict;


my $prefix = "---
layout: default
title: CosmicOS message
---

";
my $postfix = "
";

my $ct = 0;

my $out = 0;

sub Post {
#    my $current = shift;
#    my $id = shift;
#    open(FIN,"<$current") || die "Cannot open $current for reading";
#    open(FPROC,">iconic-section-$id.html");
#    while (<FIN>) {
#	if ($_ =~ /\?s=([0-3]+)\'/) {
#	    my $code = $1;
#	    my $str = AddString($code);
#	    print FPROC $str;
#	}
#    }
#    close(FPROC);
#    close(FIN);
}

my $current = "";
my $id = "";

while (<STDIN>) {
    my $txt = $_;
    if ($_ =~ /\<HR/) {
	if ($out) {
	    print FOUT $postfix;
	    close(FOUT);
	    Post($current,$id);
	}
	$id = sprintf("%06d",$ct);
	$current = "message-section-" . $id . ".html";
	open(FOUT,">$current");
	print FOUT $prefix;
#	print FOUT "<CENTER><TABLE WIDTH=40% BORDER=1 CELLPADDING=10 CELLSPACING=10><TR><TD><B>Section ", int($id), "</B><BR>Want more of a challenge? View in <A HREF='iconic-section-$id.html'>iconic</A> form (<I>experimental</I>)</TD></TR></TABLE></CENTER><P><BR>\n";
	$out = 1;
	$ct = $ct + 1;
    }
    if ($out) {
	print FOUT $txt;
    }
}
if ($out) {
    print FOUT $postfix;
    close(FOUT);
    Post($current,$id);
}

