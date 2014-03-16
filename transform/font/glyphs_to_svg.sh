#!/bin/bash

set -e

echo "New()" > ff.ff
echo "Reencode(\"unicode\")" >> ff.ff

let cursor=61696 # this is 0xf100
for f in `ls -1 coschar*.png`; do
    b=`basename $f .png`
    convert $f text.pgm && potrace --svg text.pgm
    mv text.svg $b.svg
    rm -f text.pgm
    # echo "Print(\"$b\");" >> ff.ff
    echo "Select($cursor);" >> ff.ff
    echo "Import(\"$b.svg\");" >> ff.ff
    let cursor=$cursor+1
done

echo "Generate(\"test.ttf\")" >> ff.ff

# after all that, let's just leave it for fontcustom to generate the font
# fontforge -script ff.ff

