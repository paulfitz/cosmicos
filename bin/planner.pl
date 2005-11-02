#!/usr/bin/perl -w

use strict;

use Tie::File;

if ($#ARGV<0) {
    print "Please call with name of dependency file, often depend.txt\n";
    exit(1);
}

my $dep_file = $ARGV[0];

tie my @depend, 'Tie::File', $dep_file;

my %nesting;

my @sources;

my $off = 0;

foreach my $d (@depend) {
    my $dd = $d;
    $dd =~ s/\#.*//g;
    if ($dd =~ /TERMINATE/) {
	$off = 1;
    }
    if ($dd =~ /([^:]*)\:[ \t]*(.*)/) {
	my $src = $1;
	my $target = $2;
	$target =~ s/^[ \t]*//;
	$target =~ s/[ \t]*$//;
	my @targets = split(/[ \t]+/,$target);
	#print "[$src] depends on [", join(',',@targets), "]\n";
	if (!$off) {
	    $nesting{$src} = \@targets;
	    push(@sources,$src);
	}
    }
}

my %done;

sub implement {
    my @result = ();
    #print "Looking at [", join(",",@_), "]\n";
    while ($#_>=0) {
	my $curr = shift;
	if (!defined($done{$curr})) {
	    $done{$curr} = 1;
	    push(@result,implement(@{$nesting{$curr}}));
	    #print "$curr\n";
	    push(@result,$curr);
	}
    }
    return @result;
}

sub append {
    my $str = shift;
    my @result = ();
    foreach my $v (@_) {
	push(@result,"$v$str");
    }
    return @result;
}

sub add {
    my $root = shift;
    my $postfix = shift;
    my $txt = "";
    if (-e "src/$root.$postfix") { $txt .= "$root.ftz: $root.$postfix\n";  }
    return $txt;
}

my @result = implement(@sources);


foreach my $src (@sources) {
#    print "$src.ftz: $src.pl ", join(" ", append(".ftz",@{$nesting{$src}})), "\n";
}

print "all.txt: Makefile.plan $dep_file ", join(" ",append(".ftz",@result)),"\n";
print "\t(cd \$(OBJDIR) && cat ", join(" ",append(".ftz",@result)), ") | grep '.' | tee \$(MSGDIR)/all.txt\n\n";

print "pp.txt: Makefile.plan $dep_file ", join(" ",append(".pp",@result)),"\n";
print "\t(cd \$(OBJDIR) && cat ", join(" ",append(".pp",@result)), ") | grep '.' | tee \$(MSGDIR)/pp.txt\n\n";

my $txt = "";
foreach my $unit (@result) {
    $txt .= add($unit,"pl");
    $txt .= add($unit,"java");
    $txt .= add($unit,"gate");
    $txt .= add($unit,"scm");
}
print "$txt";



