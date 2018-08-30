#!/bin/bash

set -e

echo "Working in $1"
sleep 2
cd "$1"

rm -rf *.ff *.ttf *.pgm out/ fontcustom/ .fontcustom*

echo "New()" > ff.ff
echo "Reencode(\"unicode\")" >> ff.ff

let cursor=61696 # this is 0xf100
for f in `ls -1 *.png | sort`; do
    b=`basename $f .png`
    echo "Working on $f"
    ls -1 $f
    identify $f
    convert $f text.pgm && potrace --svg --flat text.pgm
    mv text.svg $b.svg
    # fontforge chokes on completely empty path
    sed -i 's|<path d=""/>|<path d="M 1,1"/>|' $b.svg
    rm -f text.pgm
    echo "Select($cursor);" >> ff.ff
    echo "Import(\"$b.svg\");" >> ff.ff
    let cursor=$cursor+1
done

echo "Generate(\"test.ttf\")" >> ff.ff

# after all that, let's just leave it for fontcustom to generate the font
# fontforge -script ff.ff

# actually, now we use fontcustom
fontcustom compile --no-hash -o out -n cosmic_spider

cp out/* $2
