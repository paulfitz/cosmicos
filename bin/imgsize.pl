#!/usr/bin/perl

use File::Copy;
use Socket;

sub URLsize {
  my($five) = @_;
  my($dummy, $server, $url);
  my($c1, $c2, $c3, $c4)=(0,0,0,0);

  my( $x,$y) = (0,0);

  print "URLsize: $five\n" if $debug;

  # first check the hash table (if we're using one)
  if(&istrue($UseHash) &&
     $hashx{$five}     &&
     $hashy{$five}     ){
    print "Hash " if $debug;

    $x=$hashx{$five};
    $y=$hashy{$five};
    return($x,$y);
  }

  if( $Proxy =~ /\S+/ ){
    ($dummy, $dummy, $server, $url)     = split(/\//, $Proxy, 4);
    $url=$five;
  } else {
    ($dummy, $dummy, $server, $url) = split(/\//, $five, 4);
    $url= '/' . $url;
  }

  my($them,$port) = split(/:/, $server);
  my( $iaddr, $paddr, $proto );

  $port = 80 unless $port;
  $them = 'localhost' unless $them;

  print "\nThey are $them on port $port\n" if $debug;# && $Proxy;
  print "url is $url\n" 		   if $debug;

  $_=$url;
  if( /gif/i || /jpeg/i || /jpg/i || /xbm/i || /png/i ){

    $iaddr= inet_aton( $them );
    $paddr= sockaddr_in( $port, $iaddr );
    $proto=getprotobyname('tcp');

    # Make the socket filehandle.

    if(socket(STRM, PF_INET, SOCK_STREAM, $proto) &&
       connect(STRM,$paddr) ){
      # Set socket to be command buffered.
      select(STRM); $| = 1; select(STDOUT);

      print "Getting $url\n" if $debug;

      my $str=("GET $url HTTP/1.1\n".
	       "User-Agent: Mozilla/4.08 [en] (WWWIS)\n".
	       "Accept: */*\n".
	       "Connection: close\n".
	       "Host: $them\n\n");

      print "$str" if $debug;

      print STRM $str;

      # we're looking for \n\r\n\r
      while ((ord($c1) != 10) || (ord($c2) != 13) || (ord ($c3) != 10) ||
	     (ord($c4) != 13)) {
	$c4 = $c3;
	$c3 = $c2;
	$c2 = $c1;
	read(STRM, $c1, 1);
	print "$c1" if $debug;
      }
      print "\n" if $debug;

      if ($url =~ /\.jpg$/i || $url =~ /\.jpeg$/i) {
	($x,$y) = &jpegsize(\*STRM);
      } elsif($url =~ /\.gif$/i) {
	($x,$y) = &gifsize(\*STRM);
      } elsif($url =~ /\.xbm$/i) {
	($x,$y) = &xbmsize(\*STRM);
      } elsif($url =~ /\.png$/i) {
	($x,$y) = &pngsize(\*STRM);
      } else {
	print "$url is not gif, jpeg, xbm or png (or has stupid name)";
      }

      close ( STRM );
    } else {
      # there was a problem
      print "ERROR: $!";
    }
  } else {
    print "$url is not gif, xbm or jpeg (or has stupid name)";
  }
  if(&istrue($UseHash) && $x && $y){
    $hashx{$five}=$x;
    $hashy{$five}=$y;
  }
  return ($x,$y);
}

sub istrue
{
  my( $val)=@_;
  return (defined($val) && ($val =~ /^y(es)?/i || $val =~ /true/i ));
}

sub isfalse
{
  my( $val)=@_;
  return (defined($val) && ($val =~ /^no?/i || $val =~ /false/i ));
}

# looking at the filename really sucks I should be using the first 4 bytes
# of the image. If I ever do it these are the numbers.... (from chris@w3.org)
#  PNG 89 50 4e 47
#  GIF 47 49 46 38
#  JPG ff d8 ff e0
#  XBM 23 64 65 66
sub imgsize {
  my($file)= shift @_;
  my($ref)=@_ ? shift @_ : "";
  my($x,$y)=(0,0);

  # first check the hash table (if we use one)
  # then try and open the file
  # then try the server if we know of one
  if( defined($file) && open(STRM, "<$file") ){
    binmode( STRM ); # for crappy MS OSes - Win/Dos/NT use is NOT SUPPORTED
    if ($file =~ /\.jpg$/i || $file =~ /\.jpeg$/i) {
      ($x,$y) = &jpegsize(\*STRM);
    } elsif($file =~ /\.gif$/i) {
      ($x,$y) = &gifsize(\*STRM);
    } elsif($file =~ /\.xbm$/i) {
      ($x,$y) = &xbmsize(\*STRM);
    } elsif($file =~ /\.png$/i) {
      ($x,$y) = &pngsize(\*STRM);
    } else {
      print "$file is not gif, xbm, jpeg or png (or has stupid name)";
    }
    close(STRM);
  } 
  else
  {
    ($x,$y) = URLsize(@ARGV);
  }

  return ($x,$y);
}

###########################################################################
# Subroutine gets the size of the specified GIF
###########################################################################
sub gifsize
{
  my($GIF) = @_;
  return &NEWgifsize($GIF);
}


sub OLDgifsize {
  my($GIF) = @_;
  my($type,$a,$b,$c,$d,$s)=(0,0,0,0,0,0);

  if(defined( $GIF )		&&
     read($GIF, $type, 6)	&&
     $type =~ /GIF8[7,9]a/	&&
     read($GIF, $s, 4) == 4	){
    ($a,$b,$c,$d)=unpack("C"x4,$s);
    return ($b<<8|$a,$d<<8|$c);
  }
  return (0,0);
}

# part of NEWgifsize
sub gif_blockskip {
  my ($GIF, $skip, $type) = @_;
  my ($s)=0;
  my ($dummy)='';

  read ($GIF, $dummy, $skip);	# Skip header (if any)
  while (1) {
    if (eof ($GIF)) {
#      warn "Invalid/Corrupted GIF (at EOF in GIF $type)\n";
      return "";
    }
    read($GIF, $s, 1);		# Block size
    last if ord($s) == 0;	# Block terminator
    read ($GIF, $dummy, ord($s));	# Skip data
  }
}

# this code by "Daniel V. Klein" <dvk@lonewolf.com>
sub NEWgifsize {
  my($GIF) = @_;
  my($cmapsize, $a, $b, $c, $d, $e)=0;
  my($type,$s)=(0,0);
  my($x,$y)=(0,0);
  my($dummy)='';

  return($x,$y) if(!defined $GIF);

  read($GIF, $type, 6);
  if($type !~ /GIF8[7,9]a/ || read($GIF, $s, 7) != 7 ){
#    warn "Invalid/Corrupted GIF (bad header)\n";
    return($x,$y);
  }
  ($e)=unpack("x4 C",$s);
  if ($e & 0x80) {
    $cmapsize = 3 * 2**(($e & 0x07) + 1);
    if (!read($GIF, $dummy, $cmapsize)) {
#      warn "Invalid/Corrupted GIF (global color map too small?)\n";
      return($x,$y);
    }
  }
 FINDIMAGE:
  while (1) {
    if (eof ($GIF)) {
#      warn "Invalid/Corrupted GIF (at EOF w/o Image Descriptors)\n";
      return($x,$y);
    }
    read($GIF, $s, 1);
    ($e) = unpack("C", $s);
    if ($e == 0x2c) {		# Image Descriptor (GIF87a, GIF89a 20.c.i)
      if (read($GIF, $s, 8) != 8) {
#	warn "Invalid/Corrupted GIF (missing image header?)\n";
	return($x,$y);
      }
      ($a,$b,$c,$d)=unpack("x4 C4",$s);
      $x=$b<<8|$a;
      $y=$d<<8|$c;
      return($x,$y);
    }
    if ($type eq "GIF89a") {
      if ($e == 0x21) {		# Extension Introducer (GIF89a 23.c.i)
	read($GIF, $s, 1);
	($e) = unpack("C", $s);
	if ($e == 0xF9) {	# Graphic Control Extension (GIF89a 23.c.ii)
	  read($GIF, $dummy, 6);	# Skip it
	  next FINDIMAGE;	# Look again for Image Descriptor
	} elsif ($e == 0xFE) {	# Comment Extension (GIF89a 24.c.ii)
	  &gif_blockskip ($GIF, 0, "Comment");
	  next FINDIMAGE;	# Look again for Image Descriptor
	} elsif ($e == 0x01) {	# Plain Text Label (GIF89a 25.c.ii)
	  &gif_blockskip ($GIF, 12, "text data");
	  next FINDIMAGE;	# Look again for Image Descriptor
	} elsif ($e == 0xFF) {	# Application Extension Label (GIF89a 26.c.ii)
	  &gif_blockskip ($GIF, 11, "application data");
	  next FINDIMAGE;	# Look again for Image Descriptor
	} else {
	  printf STDERR "Invalid/Corrupted GIF (Unknown extension %#x)\n", $e;
	  return($x,$y);
	}
      }
      else {
	printf STDERR "Invalid/Corrupted GIF (Unknown code %#x)\n", $e;
	return($x,$y);
      }
    }
    else {
#      warn "Invalid/Corrupted GIF (missing GIF87a Image Descriptor)\n";
      return($x,$y);
    }
  }
}

sub xbmsize {
  my($XBM) = @_;
  my($input)="";

  if( defined( $XBM ) ){
    $input .= <$XBM>;
    $input .= <$XBM>;
    $input .= <$XBM>;
    $_ = $input;
    if( /.define\s+\S+\s+(\d+)\s*\n.define\s+\S+\s+(\d+)\s*\n/i ){
      return ($1,$2);
    }
  }
  return (0,0);
}

#  pngsize : gets the width & height (in pixels) of a png file
# cor this program is on the cutting edge of technology! (pity it's blunt!)
#  GRR 970619:  fixed bytesex assumption
sub pngsize {
  my($PNG) = @_;
  my($head) = "";
# my($x,$y);
  my($a, $b, $c, $d, $e, $f, $g, $h)=0;

  if(defined($PNG)				&&
     read( $PNG, $head, 8 ) == 8		&&
     $head eq "\x89\x50\x4e\x47\x0d\x0a\x1a\x0a" &&
     read($PNG, $head, 4) == 4			&&
     read($PNG, $head, 4) == 4			&&
     $head eq "IHDR"				&&
     read($PNG, $head, 8) == 8 			){
#   ($x,$y)=unpack("I"x2,$head);   # doesn't work on little-endian machines
#   return ($x,$y);
    ($a,$b,$c,$d,$e,$f,$g,$h)=unpack("C"x8,$head);
    return ($a<<24|$b<<16|$c<<8|$d, $e<<24|$f<<16|$g<<8|$h);
  }
  return (0,0);
}

# jpegsize : gets the width and height (in pixels) of a jpeg file
# Andrew Tong, werdna@ugcs.caltech.edu           February 14, 1995
# modified slightly by alex@ed.ac.uk
sub jpegsize {
  my($JPEG) = @_;
  my($done)=0;
  my($c1,$c2,$ch,$s,$length, $dummy)=(0,0,0,0,0,0);
  my($a,$b,$c,$d);

  if(defined($JPEG)		&&
     read($JPEG, $c1, 1)	&&
     read($JPEG, $c2, 1)	&&
     ord($c1) == 0xFF		&&
     ord($c2) == 0xD8		){
    while (ord($ch) != 0xDA && !$done) {
      # Find next marker (JPEG markers begin with 0xFF)
      # This can hang the program!!
      while (ord($ch) != 0xFF) { return(0,0) unless read($JPEG, $ch, 1); }
      # JPEG markers can be padded with unlimited 0xFF's
      while (ord($ch) == 0xFF) { return(0,0) unless read($JPEG, $ch, 1); }
      # Now, $ch contains the value of the marker.
      if ((ord($ch) >= 0xC0) && (ord($ch) <= 0xC3)) {
	return(0,0) unless read ($JPEG, $dummy, 3);
	return(0,0) unless read($JPEG, $s, 4);
	($a,$b,$c,$d)=unpack("C"x4,$s);
	return ($c<<8|$d, $a<<8|$b );
      } else {
	# We **MUST** skip variables, since FF's within variable names are
	# NOT valid JPEG markers
	return(0,0) unless read ($JPEG, $s, 2);
	($c1, $c2) = unpack("C"x2,$s);
	$length = $c1<<8|$c2;
	last if (!defined($length) || $length < 2);
	read($JPEG, $dummy, $length-2);
      }
    }
  }
  return (0,0);
}

sub GetImageSize
{
    $fname = shift;
    $maxw = shift;
    my $x, $y;
    ($x, $y) = imgsize($fname);
    while ($x>$maxw)
      {
	$x = int($x/2);
	$y = int($y/2);
      }
    if ($x>0 || $y>0)
    {
	return "WIDTH=$x HEIGHT=$y\n";
    }
    return "";
}


print GetImageSize(@ARGV,10000);

