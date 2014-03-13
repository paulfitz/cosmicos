
HAXELANG=js
#HAXELANG=php
#HAXELANG=cpp

default: audio eval

audio:
	haxe -$(HAXELANG) CosmicAudio.$(HAXELANG) -main cosmicos.Sound

eval:
	haxe -$(HAXELANG) CosmicEval.$(HAXELANG) -main cosmicos.Evaluate

test:
	NODE_PATH=$(PWD) node ./test_audio.js
	NODE_PATH=$(PWD) node ./test_eval.js

