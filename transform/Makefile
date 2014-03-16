
COSMIC_SITE=$(PWD)/../site/cosmicos

HAXELANG=js
#HAXELANG=php
#HAXELANG=cpp

default: audio eval

audio:
	haxe -$(HAXELANG) CosmicAudio.$(HAXELANG) -main cosmicos.Sound

eval:
	haxe -$(HAXELANG) CosmicEval.$(HAXELANG) -main cosmicos.Evaluate

scrawl:
	haxe -$(HAXELANG) SpiderScrawl.$(HAXELANG) -main cosmicos.SpiderScrawl
	NODE_PATH=$(PWD) node ./test_scrawl.js

font: scrawl
	mkdir -p vectors
	NODE_PATH=$(PWD) node ./font/generate_glyphs.js
	cd vectors && ../font/glyphs_to_svg.sh
	cd font && fontcustom compile

install-font:
	test -e $(COSMIC_SITE)/_config.yml
	cp -v font/app/assets/fonts/fontcustom_*.woff $(COSMIC_SITE)/fonts/cosmic_spider.woff
	cp -v font/app/assets/fonts/fontcustom_*.eot $(COSMIC_SITE)/fonts/cosmic_spider.eot
	cp -v font/app/assets/fonts/fontcustom_*.ttf $(COSMIC_SITE)/fonts/cosmic_spider.ttf
	cp -v font/app/assets/fonts/fontcustom_*.svg $(COSMIC_SITE)/fonts/cosmic_spider.svg

msg:
	NODE_PATH=$(PWD) node ./msg2glyphs.js ../msg/unwrapped.txt | grep "<br" | sed "s|^|<span>|" | sed "s|<br|</span><br|" | tee ../msg/glyph.txt
	head -n 25 ../msg/glyph.txt > ../msg/glyph_head.txt

msg-install:
	test -e $(COSMIC_SITE)/_config.yml
	cp -v ../msg/glyph*.txt $(COSMIC_SITE)/_includes

test:
	NODE_PATH=$(PWD) node ./test_audio.js
	NODE_PATH=$(PWD) node ./test_eval.js

