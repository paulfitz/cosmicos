#!/usr/bin/perl -w

use strict;

use GD;
use CGI qw/:standard/;

#my $style = "cross";
#my $style = "zig";
my $style = "zag";

my $w = 16;
my $h = 16;

my $ww = 640;
my $hh = 480;

# can render up to 8 bits in a single glyph
# not sure if that is desirable however
my $bits = 8;

my $im = new GD::Image($ww,$hh);

my $white = $im->colorAllocate(255,255,255);
my $black = $im->colorAllocate(0,0,0);       
my $red = $im->colorAllocate(255,0,0);      
my $blue = $im->colorAllocate(0,0,255);
my $gray = $im->colorAllocate(200,200,200);

my $color = $blue;
my $mid_color = $gray;


if ($style eq "zig" || $style eq "zag") {
    $bits = 4;
    $mid_color = $color;
}


sub ShowMid {
    my $im = shift;
    my $x0 = shift;
    my $y0 = shift;
    my $dx = shift;
    my $dy = shift;
    my $s = $w*0.75*0.5;
    $im->line($w/2+$s*$dx+$x0,$h/2+$s*$dy+$y0,
	      $w/2-$s*$dx+$x0,$h/2-$s*$dy+$y0,
	      $mid_color);
}

sub ShowEdge {
    my $im = shift;
    my $x0 = shift;
    my $y0 = shift;
    my $dx = shift;
    my $dy = shift;
    my $s = $w*0.75*0.5;
    $im->line($w/2+$s*$dx+$s*$dy+$x0,$h/2+$s*$dy-$s*$dx+$y0,
	      $w/2+$s*$dx-$s*$dy+$x0,$h/2+$s*$dy+$s*$dx+$y0,
	      $blue);
}


    

sub ShowCorner {
    my $im = shift;
    my $x0 = shift;
    my $y0 = shift;
    my $dx = shift;
    my $dy = shift;
    my $dir = shift;
    my $s = $w*0.75*0.5*0.5;
    if ($dir) {
	$im->line($w/2+$x0,$h/2+$y0,
		  $w/2+$s*2*$dx+$x0,$h/2+$s*2*$dy+$y0,
		  $blue);
    } else {
	$im->line($w/2+$s*$dx+$s*$dy+$x0,$h/2+$s*$dy-$s*$dx+$y0,
		  $w/2+$s*$dx-$s*$dy+$x0,$h/2+$s*$dy+$s*$dx+$y0,
		  $blue);
    }
}

sub ShowPart {
    my $im = shift;
    my $x0 = shift;
    my $y0 = shift;
    my $id = shift;
    if ($id==0) {
	ShowEdge($im,$x0,$y0,0,-1);
    } elsif ($id==1) {
	ShowEdge($im,$x0,$y0,-1,0);
    } elsif ($id==2) {
	ShowEdge($im,$x0,$y0,0,1);
    } elsif ($id==3) {
	ShowEdge($im,$x0,$y0,1,0);
    } elsif ($id==4) {
	ShowCorner($im,$x0,$y0,-1,-1,1);
    } elsif ($id==5) {
	ShowCorner($im,$x0,$y0,-1,+1,1);
    } elsif ($id==6) {
	ShowCorner($im,$x0,$y0,+1,+1,1);
    } elsif ($id==7) {
	ShowCorner($im,$x0,$y0,+1,-1,1);
    } else {
	exit(1);
    }
}



sub ShowCharGlyphCross {
    my $im = shift;
    my $x0 = shift;
    my $y0 = shift;
    my $has_num = shift;
    my $num = shift;
    my $open = shift;
    my $close = shift;

    my $all = 0;
    
    if ($has_num) {
	ShowMid($im,$x0,$y0,0,1);
	ShowMid($im,$x0,$y0,1,0);    
    }
    
    if ($open) {
	ShowMid($im,$x0,$y0,1,0);
	ShowCorner($im,$x0,$y0,-1,-1,0);
	ShowCorner($im,$x0,$y0,-1,+1,0);
    }
    
    if ($close) {
	ShowMid($im,$x0,$y0,1,0);
	ShowCorner($im,$x0,$y0,+1,-1,0);
	ShowCorner($im,$x0,$y0,+1,+1,0);
    }
    
    if ($num>0) {
	my $n = $num;
	for (my $i=0; $i<8; $i++) {
	    if ($n%2!=0) {
		ShowPart($im,$x0,$y0,$i);
		#print STDERR "$i\n";
	    }
	    $n = ($n-$n%2)/2;
	}
    }

    if ($all) {
	ShowMid($im,$x0,$y0,1,0);
	ShowMid($im,$x0,$y0,0,1);
	ShowEdge($im,$x0,$y0,-1,0);
	ShowEdge($im,$x0,$y0,1,0);
	ShowEdge($im,$x0,$y0,0,1);
	ShowEdge($im,$x0,$y0,0,-1);
	ShowCorner($im,$x0,$y0,-1,-1,0);
	ShowCorner($im,$x0,$y0,-1,+1,0);
	ShowCorner($im,$x0,$y0,+1,-1,0);
	ShowCorner($im,$x0,$y0,+1,+1,0);
	ShowCorner($im,$x0,$y0,-1,-1,1);
	ShowCorner($im,$x0,$y0,-1,+1,1);
	ShowCorner($im,$x0,$y0,+1,-1,1);
	ShowCorner($im,$x0,$y0,+1,+1,1);
    }
}

sub ShowCharGlyphZig {
    my $im = shift;
    my $x0 = shift;
    my $y0 = shift;
    my $has_num = shift;
    my $num = shift;
    my $open = shift;
    my $close = shift;

    my $all = 0;
    
    if ($has_num) {
	if ($num == 0) {
	    for (my $i=4; $i<8; $i++) {
		ShowPart($im,$x0,$y0,$i);
	    }
	}
    }
    
    if ($open) {
	ShowMid($im,$x0,$y0,1,0);
    }
    
    if ($close) {
	ShowMid($im,$x0,$y0,0,1);
    }
    
    if ($num>0) {
	my $n = $num;
	for (my $i=0; $i<4; $i++) {
	    if ($n%2!=0) {
		ShowPart($im,$x0,$y0,$i);
		ShowPart($im,$x0,$y0,$i+4);
	    }
	    $n = ($n-$n%2)/2;
	}
    }
}

sub ShowCharGlyphZag {
    my $im = shift;
    my $x0 = shift;
    my $y0 = shift;
    my $has_num = shift;
    my $num = shift;
    my $open = shift;
    my $close = shift;

    my $all = 0;
    
    if ($has_num) {
	if ($num == 0) {
	    ShowCorner($im,$x0,$y0,-1,-1,0);
	    ShowCorner($im,$x0,$y0,-1,+1,0);
	    ShowCorner($im,$x0,$y0,+1,-1,0);
	    ShowCorner($im,$x0,$y0,+1,+1,0);
	}
    }
    
    if ($open) {
	ShowPart($im,$x0,$y0,1);
	ShowPart($im,$x0,$y0,2);
    }
    
    if ($close) {
	ShowPart($im,$x0,$y0,0);
	ShowPart($im,$x0,$y0,3);
    }
    
    if ($num>0) {
	my $n = $num;
	for (my $i=0; $i<4; $i++) {
	    if ($n%2!=0) {
		if ($i==0) {
		    ShowMid($im,$x0,$y0,0,1);
		} elsif ($i==1) {
		    ShowPart($im,$x0,$y0,4);
		    ShowPart($im,$x0,$y0,6);
		} elsif ($i==2) {
		    ShowMid($im,$x0,$y0,1,0);
		} elsif ($i==3) {
		    ShowPart($im,$x0,$y0,5);
		    ShowPart($im,$x0,$y0,7);
		}
	    }
	    $n = ($n-$n%2)/2;
	}
    }
}


sub ShowCharGlyph {
    if ($style eq "cross") {
	ShowCharGlyphCross(@_);
    }
    elsif ($style eq "zig") {
	ShowCharGlyphZig(@_);
    }
    elsif ($style eq "zag") {
	ShowCharGlyphZag(@_);
    }
}

$im->rectangle(0,0,$ww-1,$hh-1,$white);
my $im_x = 0;
my $im_y = 0;
my $im_dirty = 0;

sub RenewImage {
    $im->filledRectangle(0,0,$ww-1,$hh-1,$white);
    $im_x = 0;
    $im_y = 0;
    $im_dirty = 0;
}

RenewImage();

my $imageCt = 0;

my @images = ();

sub FlushImage {
    if ($im_dirty) {
	my $fname = "iconic-" . sprintf("%06d",$imageCt) . ".png";
	print STDERR "Saving message to $fname\n";
	push(@images,$fname);
	open(FOUT,">$fname");
	binmode FOUT;
	print FOUT $im->png;
	$imageCt++;
    }
    RenewImage();
}


sub IncLine {
    if ($im_x!=0) {
	$im_x = 0;
	$im_y = $im_y + $h;
	if ($im_y+$h>$hh) {
	    FlushImage();
	}
    }
}
sub IncPos {
    $im_x = $im_x + $w;
    if ($im_x+$w>$ww) {
	IncLine();
    }
}


my $mode = 0;
my $paren = 0;
my $q = "";


sub ShowChar {
    my $h = shift;
    my $n = shift;
    my $o = shift;
    my $c = shift;
    ShowCharGlyph($im,$im_x,$im_y,$h,$n,$o,$c);
    $im_dirty = 1;
    IncPos();
    return "<IMG SRC='chars/char$o$c$h$n.png' WIDTH=16 HEIGHT=16> ";
#    print "<IMG SRC='showchar.pl?n=$n&o=$o&c=$c' WIDTH=16 HEIGHT=16> ";
}

sub AddChar {
    my $txt = "";
    my $ch = shift;
    if ($ch eq "2") {
	if ($mode) {
	    $txt = $txt . ShowChar(0,0,1,0);
	} else {
	    $mode = 1;
	}
	$paren++;
    } elsif ($ch eq "3") {
	$paren--;
	if ($mode) {
	    if (length($q)>100) {
		$txt = $txt . ShowChar(0,0,1,0);
		for (my $i=0; $i<length($q); $i++) {
		    $txt = $txt . ShowChar(1,int(substr($q,$i,1)),0,0);
		}
		$txt = $txt . ShowChar(0,0,0,1);
	    } elsif (length($q)>0) {
		my $len = length($q);
		while ($len%$bits!=0) {
		    $q = "0$q";
		    $len = length($q);
		}
		my $blen = int(($len-1)/$bits+1);
		for (my $i=0; $i<$blen; $i++) {
		    my $part = substr($q,$i*$bits,$bits);
		    my $v = oct("0b$part");
		    #print "[==$part==$v==]";
		    $txt = $txt . ShowChar(1,$v,($i==0)?1:0,($i==$blen-1)?1:0);
		}
	    } else {
		$txt = $txt . ShowChar(0,0,1,1);
	    }
	    #print "[($q)]";
	    $q = "";
	    $mode = 0;
	} else {
	    $txt = $txt . ShowChar(0,0,0,1);
	}
    } else {
	if ($mode) {
	    $q = $q . $ch;
	} else {
	    $txt = $txt . ShowChar(1,int($ch),0,0);
	}
    }
    return $txt;
}

my $last4 = "";

sub AddString {
    my $txt = shift;
    my $breaker = shift;
    for (my $i=0; $i<length($txt); $i++) {
	my $ch = substr($txt,$i,1);
	AddChar($ch);
	if (length($last4)>=4) {
	    $last4 = substr($last4,1,3) . $ch;
	} else {
	    $last4 = $last4 . $ch;
	}
	if ($last4 eq "2233") {
	    IncLine();
	}
    }
}

my $html = 0;

while (<>) {
    chomp($_);
    if ($_ =~ /\</) {
	$html = 1;
    }
    if ($html) {
	if ($_ =~ /\?s=([0-3]+)[\'\"]/) {
	    AddString($1,0);
	    IncLine();
	}
    } else {
	AddString($_,1);
    }
}

FlushImage();

my @pages = ();
for (my $i=0; $i<=$#images; $i++) {
    my $image = $images[$i];
    my $fname = $image;
    $fname =~ s/\.png/\.html/;
    push(@pages,$fname);
}

for (my $i=0; $i<=$#images; $i++) {
    my $image = $images[$i];
    my $page = $pages[$i];
    open(FOUT,">$page");
    print FOUT "<center>\n";
    my $prev_txt = "&lt; previous";
    my $first_txt = "&lt;&lt; first";
    if ($i>0) {
	$prev_txt = "<A HREF=" . $pages[$i-1] . ">$prev_txt</A>";
	$first_txt = "<A HREF=" . $pages[0] . ">$first_txt</A>";
    }
    print FOUT "$first_txt&nbsp;&nbsp;&nbsp;$prev_txt&nbsp;&nbsp;&nbsp;";
    print FOUT "<B>Page " . ($i+1) . " of " . ($#images+1) . "</B>\n";
    my $next_txt = "next &gt;";
    my $last_txt = "last &gt;&gt;";
    if ($i<$#images) {
	$next_txt = "<A HREF=" . $pages[$i+1] . ">$next_txt</A>";
	$last_txt = "<A HREF=" . $pages[$#images] . ">$last_txt</A>";
    }
    print FOUT "&nbsp;&nbsp;&nbsp;$next_txt";    
    print FOUT "&nbsp;&nbsp;&nbsp;$last_txt";
    print FOUT "<BR><BR>\n";
#    if ($i>0) {
#	print FOUT "<A HREF=" . $pages[$i-1] . ">return to previous page<A><BR>\n";
#    } else {
#	print FOUT "&nbsp;<BR>\n";
#    }
    if ($i<$#images) {
	print FOUT "<A HREF=" . $pages[$i+1] . "><IMG SRC=$image BORDER=0><A><BR>\n";
	print FOUT "<A HREF=" . $pages[$i+1] . ">click for more...<A><BR>\n";
    } else {
	print FOUT "<IMG SRC=$image><BR>\n";
	print FOUT "&nbsp;<BR>\n";
    }
    print FOUT "<BR><BR><A HREF=index.html>return to message index</a>\n";
    print FOUT "</center>\n";

    close(FOUT);
}

