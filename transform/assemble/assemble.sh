#!/bin/bash

set -e

ORG="$PWD"
SRC="$PWD/../src"
BIN="$PWD/../bin"
BASE="$PWD/.."

if [ ! -e $BIN/UnlessDriver.class ] ; then
    echo "Missing UnlessDriver"
    echo "For now, you need to use old Make machinery first"
    exit 1
fi

for f in `cat ../depend.txt | grep ":" | sed "s/:.*//"`; do
    echo "== $f =="

    if [ -e "$SRC/$f.pl" ]; then
	perl -I$SRC $SRC/$f.pl
    elif [ -e "$SRC/$f.scm" ]; then
	cat $SRC/$f.scm
    elif [ -e "$SRC/$f.gate" ]; then
	# this is messy, need to redo
	cd $SRC
	java -cp $BIN:$SRC UnlessDriver $f.gate > /tmp/gate.$f.tmp
	cd $ORG
	cat /tmp/gate.$f.tmp | $PWD/../bin/drawgate-txt.pl | sed "s/IMAGE_SRC/IMAGE_SRC=$f.gif/" | sed "s/CIRCUIT_NAME/`echo $f | tr '[:upper:]' '[:lower:]'`/g"
	cat /tmp/gate.$f.tmp | $PWD/../bin/drawgate-ppm.pl > $f.ppm
	cat /tmp/gate.$f.tmp
    elif [ -e "$SRC/$f.java" ]; then
	# need BCEL library (http://jakarta.apache.org/bcel/)
	if grep -q "STUB:" $SRC/$f.java ; then
	    grep "STUB:" $SRC/$f.java | sed "s/^.*: //" | sed "s/ \*\///"
	else
	    cd $BASE
	    javac -source 1.4 -classpath /usr/share/java/bcel.jar:.:$SRC src/$f.java
	    java -cp /usr/share/java/bcel.jar:.:$SRC:$BIN Fritzifier $f
	    mv $f.ftz /tmp/cosmicos.ftz
	    cd $ORG
	    $BIN/java-comment.pl /tmp/cosmicos.ftz $SRC/$f.java 
	fi
    else
	echo "Cannot handle $f"
	ls $SRC/$f.*
	exit 1
    fi
done
