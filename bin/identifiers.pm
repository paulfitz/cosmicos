#!usr/bin/perl -w

use strict;

sub GetIDs {
    my %id;

    $id{"/"} = -1;

    $id{"demo"} = 7;
    $id{"equal"} = 8;
    $id{"vector"} = 16;

    $id{"intro"} = 0;
    $id{"="} = 2;
    $id{">"} = 3;
    $id{"<"} = 1;
    $id{"not"} = 4;
    $id{"and"} = 5;
    $id{"or"} = 6;

    $id{"*"} = 9;
    $id{"+"} = 10;
    $id{"-"} = 11;

    $id{"?"} = 12;
    $id{"define"} = 13;
    $id{"assign"} = 14;
    $id{"if"} = 15;

#    $id{">="} = 10;
#    $id{"false"} = 15;
#    $id{"true"} = 16;
    $id{"forall"} = 19;
    $id{"exists"} = 20;
    $id{"cons"} = 21;
    $id{"car"} = 22;
    $id{"cdr"} = 23;
    $id{"number?"} = 24;
    $id{"translate"} = 25;
    $id{"lambda"} = 26;
    $id{"make-cell"} = 27;
    $id{"set!"} = 28;
    $id{"get!"} = 29;
    $id{"all"} = 30;
    $id{"natural-set"} = 31;
    $id{"undefined"} = 32;
    $id{"!"} = 33;
    $id{"div"} = 34;
    $id{"primer"} = 35;
    return \%id;
}

sub GetFreeID {
    my $free_id = 36;
    return $free_id;
}

1;
