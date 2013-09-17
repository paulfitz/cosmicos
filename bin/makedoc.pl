#!/usr/bin/perl -w

use strict;

use Math::BigInt;

sub AsString {
    my $num = shift;
    my $val = Math::BigInt->new($num);
    my $str = "";
    while (!($val->is_zero())) {
	my ($quo, $rem) = $val->bdiv(256);
	$str = chr($rem) . $str;
	$val = $quo;
    }
    my $ok = 0;
    my $result = "$num";
    if (length($str)>=3) {
	my $ch = substr($str,0,1);
	if (ord($ch)>=ord("a") && ord($ch)<=ord("z")) {
	    $ok = 1;
	}
    }
    if ($ok) {
	$result = "\"$str\"";
    }
    return $result;
}

sub Value {
    my $in = shift;
    my $out = "";
    my $at = 0;
    my $arg = 0;
    $in =~ s/\;.*//g;
    for (my $i=0; $i<length($in); $i++) {
	my $ch = substr($in,$i,1);
	if ($ch eq "(") { $at++; }
	if ($ch eq ")") { $at--; }
	if ($ch eq " " && $at == 0) {
	    $arg++;
	    if ($arg==2) {
		$out = substr($in,$i+1,length($in)-$i);
		$out =~ s/^\-1 (.*)/\($1\)/;
		$out =~ s/\(16 /\(vector /g;
		last;
	    }
	}
    }

    $in = "$out ";
    $out = "";
    my $cache = "";
    for (my $i=0; $i<length($in); $i++) {
	my $ch = substr($in,$i,1);
	if ($ch =~ /[0-9]/) {
	    $cache .= $ch;
	} else {
	    if ($cache ne "") {
		$out .= AsString($cache);
		$cache = "";
	    }
	    $out .= $ch;
	}
    }
    $out =~ s/ $//;

    return $out;
}


sub SaveBlock {
    my $code = shift;
    my $txt = shift;
    open(BLK,">msg/block_" . $code . ".txt");
    print BLK $txt;
    close(BLK);
}

my $showed_embedding = 0;
my $showed_string_embedding = 0;

if ($#ARGV<1) 
  {
    die "not enough arguments";
  }

my $BASEDIR = $ARGV[0];
my $BASEFILE = $ARGV[1];

open(COM,"<www-src/COMMENTS.TXT");
my $txt = "";
while(<COM>)
  {
    $txt .= $_;
  }

open(REF,"<msg/unwrapped.txt");
my @ref = ();
my $sym_ct = 0;
while(<REF>)
  {
    chomp;
    push(@ref,$_);
    $sym_ct += length($_);
  }

open(DEMO,"<msg/numeric.txt");
my @demo = ();
my $demo_line = "";
while(<DEMO>)
  {
    chomp;
    if (!($_ =~ /\#/)) {
	$demo_line .= "$_ ";
	if ($demo_line =~ /\;/) {
	    push(@demo,$demo_line);
	    $demo_line = "";
	}
    }
  }


my $txt0 = $txt;
my $txt1 = $txt;
$txt0 =~ s/[\n\r]*MORE(.|[\n\r])*//;
$txt1 =~ s/(.|[\n\r])*MORE.*[\n\r]*//;
$txt0 =~ s/\n\n+/\<P\>/g;
$txt1 =~ s/\n\n+/\<P\>/g;

open(MSG,"<msg/color.txt");
my $msg = "";
while(<MSG>)
  {
      $_ =~ s/u(1*)u/0${1}0/g;
      $msg .= $_;
  }

open(AMSG,">www/message-verbose.html");
my $imsg = "";

print AMSG "<HTML><HEAD><TITLE>CosmicOS message</TITLE></HEAD>\n";
print AMSG "<BODY BGCOLOR='#ffffff'>\n";
my $name = 0;
my $ref_index = 0;
my $intro = 0;
for my $m (split(/\n/,$msg))
  {
    my $s = $m;
    $s =~ s/\&/&amp;/g;
    $s =~ s/\</&lt;/g;
    $s =~ s/\>/&gt;/g;
    $s =~ s/\&lt\;font style=\'background\-color\: \#(......)\'\&gt\;/\<font style=\'background\-color\: \#$1\'\>/g;
    $s =~ s/\&lt\;\/font\&gt\;/\<\/font\>/g;
    my $prefix = "";
    my $postfix = "";
    my $novel = 1;
    if ($m =~ /\#  ?[A-Z][A-Z]/)
      {
	if ($s =~ /\# *([A-Z]+) *(.*)/)
	  {
	    my $sect = $1;
	    my $comment = $2;
	    $prefix = "<A NAME='$name'><FONT COLOR=red>";

	    my $f1 = "";
	    my $f2 = "";
	    if ($sect =~ /NOTE/) {
		$f1 = "<font color=red><b>";
		$f2 = "</b></font>";
	    }

	    $imsg .= "<TR><TD ALIGN=RIGHT><A HREF='message-section-" . sprintf("%06d",$name) . ".html'>$name</A> </TD><TD>&nbsp;&nbsp;</TD><TD> $f1$comment$f2 </TD><TD> $f1($sect)$f2 </TD></TR>\n";
	    $name = $name+1;
	    $postfix = "</FONT></A>";
	    if (!$intro) {
		print AMSG "<HR>\n";
		$intro = 1;
	    }
	  }
	$novel = 0;
      }
    if ($s =~ /^([ \t]+)/)
      {
	my $space = $1;
	$space =~ s/\t/    /g;
	$space =~ s/ /\&nbsp\;/g;
	$s =~ s/^[ \t]+/$space/;
	$novel = 0;
      }
    my $s2 = $s;
    if ($s =~ /^\#/) { 
	$novel = 0; 
	if ($s =~ /^(\#[ \t]+)/) {
	    my $f = $1;
	    my $qf = quotemeta($f);
	    $f =~ s/ /\&nbsp\;/g;
	    $f =~ s/\t/\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;/g;
	    $s2 =~ s/^$qf/$f/;
	}
    }
    my $basic_index = -1;
    if ($novel) {
	$intro = 0;
	print AMSG "<TT>[<A HREF='sound.cgi?s=$ref[$ref_index]'>hear</A>] </TT>";
	$basic_index = $ref_index;
	if (!defined($ref[$ref_index])) {
	    print "PROBLEM at index $ref_index ($prefix$s2$postfix)\n";
	    exit 1;
	}
      $ref_index++;
    } else {
      print AMSG "<TT>\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;\&nbsp;</TT>";
    }
    my $outer = "$prefix$s2$postfix";
    $outer =~ s/IMAGE_SRC=([^ \<\n\r]+)/<A HREF=$1><IMG SRC=$1><\/A>/;
    print AMSG "<TT>$outer</TT><BR>\n";
    if ($m =~ /^\(demo /) {
	my $val = Value($demo[$basic_index]);
	if ($showed_embedding) {
	    print AMSG "<TT>\&nbsp;\&nbsp;\&nbsp;</TT><font size=-1 color=green>evaluates to: " . $val . "</font><BR>\n";
	} else {
	    $showed_embedding = 1;
	    print AMSG "<TT>\&nbsp;\&nbsp;\&nbsp;</TT><font size=-1 color=green>This expression is embedded in the message in the form (equal expression value)</font><BR>\n";
	    print AMSG "<TT>\&nbsp;\&nbsp;\&nbsp;</TT><font size=-1 color=green>where value is " . $val . "</font><BR>\n";
	}
	if (!$showed_string_embedding) {
	    if ($val =~ /\"/) {
		print AMSG "<TT>\&nbsp;\&nbsp;\&nbsp;</TT><font size=-1 color=green>(quoted strings are guessed; they are represented in the message as ordinary numbers)</font><BR>\n";
		$showed_string_embedding = 1;
	    }
	}
    }
    my $m = "$prefix$s$postfix";
    $m =~ s/\&[a-z]+\;//g;
    if (($m =~ /[\;]/) && !($m=~/\# /)) {
	print AMSG "<BR>\n";
    }
  }

$imsg = "<TABLE BORDER=0><TR><TD><B>Sect.</B></TD><TD></TD><TD><B>Comment</B></TD><TD><B>Type</B></TD></TR>\n$imsg</TABLE>\n";

print AMSG "<HR>\n";
print AMSG "</BODY>\n";
print AMSG "</HTML>\n";
close(AMSG);

open(TEMPLATE,"<www-src/template.html");
my $plate = "";
while(<TEMPLATE>)
  {
    $plate .= $_;
  }


my $entropy = `cp msg/wrapped.txt entropy.txt; gzip -q -f entropy.txt; wc -c < entropy.txt.gz; rm -f entropy.txt.gz`;
my $imgsize = `bin/imgsize.pl view.png`;
my $teaser = `head -n 7 msg/wrapped.txt`;
my $version = $BASEDIR;
$version =~ s/cosmic\.//g;
$entropy = $entropy/1024;
$entropy = int(0.5+$entropy*10)/10;

SaveBlock("XXX",$txt0);
SaveBlock("MMM",$txt1);
SaveBlock("DDD",$BASEDIR);
SaveBlock("FFF",$BASEFILE);
SaveBlock("III",$imsg);
SaveBlock("EEE",$entropy);
SaveBlock("SSS",$imgsize);
SaveBlock("RRR",$teaser);
SaveBlock("VVV",$version);
SaveBlock("CCC",$sym_ct);

$plate =~ s/\[XXX\]/$txt0/g;
$plate =~ s/\[MMM\]/$txt1/g;
$plate =~ s/\[DDD\]/$BASEDIR/g;
$plate =~ s/\[FFF\]/$BASEFILE/g;
$plate =~ s/\[III\]/$imsg/g;
$plate =~ s/\[EEE\]/$entropy/g;
$plate =~ s/\[SSS\]/$imgsize/g;
$plate =~ s/\[RRR\]/$teaser/g;
$plate =~ s/\[VVV\]/$version/g;
$plate =~ s/\[CCC\]/$sym_ct/g;

print $plate;

