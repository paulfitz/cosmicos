#!/bin/bash

set -e

echo "Working in $1"
sleep 2
cd "$1"

rm -rf *.ff *.ttf *.pgm out/ fontcustom/ .fontcustom*

echo "New()" > ff.ff
echo "Reencode(\"unicode\")" >> ff.ff

function add_group {
  name="$1"
  offset="$2"
  let cursor=61696+$offset # this is 0xf100 + offset
  for f in `ls -1 *_$name_*.png | sort`; do
    b=`basename $f .png`
    echo "Working on $f"
    ls -1 $f
    identify $f
    convert $f text.pgm && potrace --svg --flat text.pgm
    mv text.svg $b.svg
    # fontforge chokes on completely empty path
    # and mac fusses about sed -i
    sed 's|<path d=""/>|<path d="M 1,1"/>|' $b.svg > $b.2.svg
    rm $b.svg
    mv $b.2.svg $b.svg
    rm -f text.pgm
    echo "Select($cursor);" >> ff.ff
    echo "Import(\"$b.svg\");" >> ff.ff
    let cursor=$cursor+1
  done
}

add_group "spider" 0
add_group "octo" 512

echo "Generate(\"test.ttf\")" >> ff.ff

# after all that, let's just leave it for fontcustom to generate the font
# fontforge -script ff.ff

echo "autowidth: true" > fontcustom.yml

# actually, now we use fontcustom
fontcustom compile --no-hash -o out -n cosmic_spider

cp out/* $2
