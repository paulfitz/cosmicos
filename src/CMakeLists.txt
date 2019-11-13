add_subdirectory(java)

##############################################################################
##
## Check for haxe and node
##
##

find_program(HAXE haxe)
if(NOT HAXE)
  MESSAGE(FATAL_ERROR "Could not find haxe, please install it")
endif()

find_program(NODE NAMES nodejs node)
if(NOT NODE)
  MESSAGE(FATAL_ERROR "Could not find node, please install it")
endif()

##############################################################################
##
## Compile some basic tools for processing the message
##
##

set(WORK ${CMAKE_CURRENT_BINARY_DIR})
set(SRC ${CMAKE_SOURCE_DIR}/src)
set(MSG ${CMAKE_SOURCE_DIR}/msg)

add_custom_command(OUTPUT ${WORK}/CosmicAudio.js
  COMMAND ${HAXE} -js CosmicAudio.js -main cosmicos.Sound -cp ${SRC}
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${SRC}/cosmicos/Sound.hx)

add_custom_command(OUTPUT ${WORK}/CosmicEval.js
  COMMAND ${HAXE} -js CosmicEval.js -main cosmicos.Evaluate -cp ${SRC}
  COMMAND ${CMAKE_COMMAND} -E copy ${WORK}/CosmicEval.js ${CMAKE_BINARY_DIR}/lib/cosmicos.js
  WORKING_DIRECTORY ${WORK}
  DEPENDS 
  ${SRC}/cosmicos/BitString.hx
  ${SRC}/cosmicos/ChainCodec.hx
  ${SRC}/cosmicos/Codec.hx
  ${SRC}/cosmicos/Config.hx
  ${SRC}/cosmicos/Cons.hx
  ${SRC}/cosmicos/CosFunction.hx
  ${SRC}/cosmicos/Evaluate.hx
  ${SRC}/cosmicos/EvaluateCodec.hx
  ${SRC}/cosmicos/FourSymbolCodec.hx
  ${SRC}/cosmicos/ManuscriptStyle.hx
  ${SRC}/cosmicos/Memory.hx
  ${SRC}/cosmicos/NormalizeCodec.hx
  ${SRC}/cosmicos/Parse.hx
  ${SRC}/cosmicos/ParseCodec.hx
  ${SRC}/cosmicos/PreprocessCodec.hx
  ${SRC}/cosmicos/Statement.hx
  ${SRC}/cosmicos/TranslateCodec.hx
  ${SRC}/cosmicos/UnflattenCodec.hx
  ${SRC}/cosmicos/Vocab.hx
)

add_custom_command(OUTPUT ${WORK}/SpiderScrawl.js
  COMMAND ${HAXE} -js SpiderScrawl.js -main cosmicos.SpiderScrawl -cp ${SRC}
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${SRC}/cosmicos/SpiderScrawl.hx ${SRC}/cosmicos/GlyphCode.hx)

add_custom_command(OUTPUT ${WORK}/OghamStyle.js
  COMMAND ${HAXE} -js OghamStyle.js -main cosmicos.OghamStyle -cp ${SRC}
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${SRC}/cosmicos/OghamStyle.hx)

add_custom_target(jshelpers ALL DEPENDS 
  ${WORK}/CosmicAudio.js
  ${WORK}/CosmicEval.js
  ${WORK}/SpiderScrawl.js
  ${WORK}/OghamStyle.js)



##############################################################################
##
## Add targets for message parts
##

file(GLOB variant_files
  RELATIVE "${CMAKE_SOURCE_DIR}/variant/"
  "${CMAKE_SOURCE_DIR}/variant/*.cmake"
)
set(VARIANTS)
foreach(variant_file ${variant_files})
  get_filename_component(variant ${variant_file} NAME_WE)
  list(APPEND VARIANTS ${variant})
endforeach()
set(COSMIC_VARIANT "standard" CACHE STRING "Version of message to build (${VARIANTS})")
set(COSMIC_LINES "0" CACHE INT "Number of lines to process (0 for unlimited)")
set_property(CACHE COSMIC_VARIANT PROPERTY STRINGS ${VARIANTS})

# We expect to get these variables:
#   COSMIC_DEPENDS that lists all parts
#   COSMIC_USE_FLATTENER that controls whether '|' can be encoded
include(${CMAKE_SOURCE_DIR}/msg/BASE.cmake)
include(${CMAKE_SOURCE_DIR}/variant/${COSMIC_VARIANT}.cmake)

if(NOT COSMIC_VOCAB)
  SET(COSMIC_VOCAB ${CMAKE_SOURCE_DIR}/variant/iconic/vocab.json)
endif()

if(NOT COSMIC_NAMES)
  SET(COSMIC_NAMES ${CMAKE_SOURCE_DIR}/msg/names.json)
endif()

get_target_property(UnlessDriverLoc UnlessDriver JAR_FILE)
get_target_property(FritzifierLoc Fritzifier JAR_FILE)
FILE(WRITE ${WORK}/setup.cmake "
  set(base \"${CMAKE_SOURCE_DIR}/msg\")
  set(out_dir \"${CMAKE_CURRENT_BINARY_DIR}\")
  set(JAVA_EXE \"${Java_JAVA_EXECUTABLE}\")
  set(JAVAC_EXE \"${Java_JAVAC_EXECUTABLE}\")
  set(UNLESS \"${UnlessDriverLoc}\")
  set(ENCODER \"${FritzifierLoc}\")
  set(BCEL \"${BCEL_JAR}\")
  set(NODE \"${NODE}\")
  set(TSNODE \"${CMAKE_SOURCE_DIR}/node_modules/.bin/ts-node\")
")

set(TSC "${CMAKE_SOURCE_DIR}/node_modules/.bin/tsc")
set(WEBPACK "${CMAKE_SOURCE_DIR}/node_modules/.bin/webpack")

include(${CMAKE_SOURCE_DIR}/msg/DEPEND.cmake)
set_property(GLOBAL PROPERTY msg_list)

function(expand)
  get_property(tmp GLOBAL PROPERTY msg_list)
  foreach(depend ${ARGV})
    get_property(have_${depend} GLOBAL PROPERTY have_${depend})
    if (NOT have_${depend})
      set(req ${req_${depend}})
      if (req)
        expand(${req})
      endif()
      get_property(tmp GLOBAL PROPERTY msg_list)
      set_property(GLOBAL PROPERTY msg_list ${tmp} ${depend})
      set(have_${depend} 1)
      set_property(GLOBAL PROPERTY have_${depend} 1)
    endif()
  endforeach()
endfunction()

expand(${COSMIC_DEPENDS})
get_property(COSMIC_DEPENDS GLOBAL PROPERTY msg_list)

set(ACTIVE_DEPENDS)
set(ACTIVE_DEPENDS_SHORT "")
set(EXTRA_DEPEND_pl ${MSG}/cosmic.pm)
set(EXTRA_DEPEND_js ${MSG}/cosmic.js)
set(EXTRA_DEPEND_gate ${CMAKE_SOURCE_DIR}/src/filter/drawgate-ppm.pl ${CMAKE_SOURCE_DIR}/src/filter/drawgate-txt.pl UnlessDriver ${UnlessDriverLoc})
set(EXTRA_DEPEND_java Fritzifier ${FritzifierLoc})
foreach(depend ${COSMIC_DEPENDS})
  foreach(ext md pl scm gate java js)
    if(EXISTS ${MSG}/${depend}.${ext})
      set(POSTFIX "")
      if (${ext} STREQUAL "md")
        set(POSTFIX "_md")
      endif()
      add_custom_command(OUTPUT ${WORK}/${depend}${POSTFIX}.ftz
	COMMAND ${CMAKE_COMMAND} 
	"-Din:STRING=${depend}.${ext}" 
	"-Dout:STRING=${depend}${POSTFIX}.ftz"
	"-Dname:STRING=${depend}"
	-P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/convert_${ext}.cmake
	WORKING_DIRECTORY ${WORK}
	DEPENDS ${MSG}/${depend}.${ext} ${EXTRA_DEPEND_${ext}}
	${CMAKE_CURRENT_SOURCE_DIR}/cmake/convert_${ext}.cmake)
      list(APPEND ACTIVE_DEPENDS ${WORK}/${depend}${POSTFIX}.ftz)
      if (NOT ${ext} STREQUAL "md")
        set(ACTIVE_DEPENDS_SHORT "${ACTIVE_DEPENDS_SHORT} ${depend}")
      endif()
    endif()
  endforeach()
endforeach()

set(COSMIC_OPTION_FILE ${WORK}/config.json)
configure_file(config.json ${COSMIC_OPTION_FILE} @ONLY)

# assem.txt contains a concatenation of all message parts, in
# original textual form
add_custom_command(OUTPUT ${WORK}/assem.txt
  COMMAND ${CMAKE_COMMAND}
  "-Din:STRING=${ACTIVE_DEPENDS_SHORT}" 
  "-Dout:STRING=assem.txt"
  -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/assemble.cmake
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${ACTIVE_DEPENDS}
    ${WORK}/SpiderScrawl.js
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/assemble.cmake)

# assem.json is a structured version of assem.txt, but still in original form
add_custom_command(OUTPUT ${WORK}/assem.json
  COMMAND 
    ${NODE} ${CMAKE_SOURCE_DIR}/src/assemble/assemble2json.js ${WORK}/assem.txt
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${WORK}/assem.txt
  ${CMAKE_SOURCE_DIR}/src/assemble/assemble2json.js)

# primer.json is a numeric version of the message, for self-references.
# Note that any lines relying on self-evaluation are inaccurate.
# It is important to not refer to such lines, in order to avoid
# circularity.  Ssh.
add_custom_command(OUTPUT ${WORK}/primer.json
  COMMAND ${CMAKE_COMMAND} 
  "-Din:STRING=${CMAKE_SOURCE_DIR}/src/assemble/primer.js" 
  "-Dnargs:STRING=${WORK}/assem.json"
  "-Dlog:STRING=make-primer"
  "-Dpath:STRING=${CMAKE_SOURCE_DIR}/src/assemble"
  -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/node.cmake
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${WORK}/assem.json
  ${WORK}/CosmicEval.js
  ${CMAKE_SOURCE_DIR}/src/assemble/CosmicDrive.js
  ${CMAKE_BINARY_DIR}/js/src/cosmicos/FourSymbolCodecV2.js
  ${CMAKE_SOURCE_DIR}/src/assemble/primer.js)
add_custom_target(primer ALL DEPENDS ${WORK}/primer.json)

# assem2.json is assem.json but marked up also with message fragments
# in final form
add_custom_command(OUTPUT ${WORK}/assem2.json ${CMAKE_BINARY_DIR}/index.txt ${CMAKE_BINARY_DIR}/index.json
  COMMAND ${CMAKE_COMMAND} 
  "-Din:STRING=${CMAKE_SOURCE_DIR}/src/assemble/evaluate.js" 
  "-Dnargs:STRING="
  "-Dlog:STRING=make-assem2" 
  "-Dpath:STRING=${CMAKE_SOURCE_DIR}/src/assemble"
  -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/node.cmake
  COMMAND ${CMAKE_COMMAND} -E copy ${WORK}/assem2.json ${CMAKE_BINARY_DIR}/index.json
  COMMAND ${CMAKE_COMMAND} -E copy ${WORK}/q.txt ${CMAKE_BINARY_DIR}/index.txt
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${WORK}/assem.json
  ${COSMIC_NAMES}
  ${WORK}/primer.json
  ${WORK}/CosmicEval.js
  ${CMAKE_SOURCE_DIR}/src/assemble/CosmicDrive.js
  ${CMAKE_BINARY_DIR}/js/src/cosmicos/FourSymbolCodecV2.js
  ${CMAKE_SOURCE_DIR}/src/assemble/evaluate.js)

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/wrapped.txt ${CMAKE_BINARY_DIR}/entropy.txt
  COMMAND ${CMAKE_COMMAND} 
  "-Din:STRING=${CMAKE_BINARY_DIR}/index.txt" 
  "-Dout:STRING=${CMAKE_BINARY_DIR}/wrapped.txt"
  -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/wrap.cmake
  COMMAND ${CMAKE_COMMAND} -E tar cj ${CMAKE_BINARY_DIR}/wrapped.tar.bz2 ${CMAKE_BINARY_DIR}/wrapped.txt
  COMMAND ${CMAKE_COMMAND} 
  "-Din:STRING=${CMAKE_BINARY_DIR}/wrapped.tar.bz2" 
  "-Dout:STRING=${CMAKE_BINARY_DIR}/entropy.txt"
  -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/wc.cmake
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${CMAKE_BINARY_DIR}/index.txt
  ${CMAKE_SOURCE_DIR}/src/filter/wrap.pl
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/wrap.cmake
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/wc.cmake)

add_custom_target(assem ALL DEPENDS ${CMAKE_BINARY_DIR}/wrapped.txt)


##############################################################################
##
## Add optional targets (not in default build) for stats
##

# scan the active vocabulary
add_custom_command(OUTPUT ${WORK}/vocab.json
  COMMAND ${CMAKE_COMMAND} 
  "-Din:STRING=${CMAKE_SOURCE_DIR}/src/assemble/vocab.js" 
  "-Dnargs:STRING=${WORK}/assem.json"
  "-Dlog:STRING=make-vocab"
  -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/node.cmake
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${WORK}/assem.json
  ${WORK}/CosmicEval.js
  ${CMAKE_SOURCE_DIR}/src/assemble/vocab.js)

add_custom_target(vocab DEPENDS ${WORK}/vocab.json)

# generate old spider-script style glyphs
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/assets/icons/spider)
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/assets/fonts/spider)
add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/assets/fonts/spider/cosmic_spider.ttf
  COMMAND ${CMAKE_COMMAND} 
  "-Din:STRING=${CMAKE_SOURCE_DIR}/src/font/generate_glyphs.ts" 
  "-Dnargs:STRING=${CMAKE_BINARY_DIR}/assets"
  "-Dlog:STRING=spider"
  -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/typescript.cmake
  WORKING_DIRECTORY ${WORK}
  DEPENDS
  ${WORK}/SpiderScrawl.js
  ${CMAKE_SOURCE_DIR}/src/font/glyphs_to_svg.sh
  ${CMAKE_SOURCE_DIR}/src/font/OctoGlyph.ts
  ${CMAKE_SOURCE_DIR}/src/font/generate_glyphs.ts)

add_custom_target(spider DEPENDS ${CMAKE_BINARY_DIR}/assets/fonts/spider/cosmic_spider.ttf)


##############################################################################
##
## Add a little utility for scanning message called cosmsg
##

configure_file(${CMAKE_SOURCE_DIR}/src/cmd/cosmsg.js ${CMAKE_BINARY_DIR}/bin/cosmsg.js @ONLY)

##############################################################################
##
## Convert message to a .wav
##

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/index.wav
  COMMAND ${CMAKE_BINARY_DIR}/bin/cosmsg.js hear -p 0 -P -2 -v ${COSMIC_VOCAB} -nc
    -o ${CMAKE_BINARY_DIR}/index.wav > ${CMAKE_BINARY_DIR}/src/wav.txt
  WORKING_DIRECTORY ${WORK}
  DEPENDS
  ${COSMIC_VOCAB}
  ${CMAKE_BINARY_DIR}/index.json
  ${WORK}/CosmicAudio.js
  ${CMAKE_SOURCE_DIR}/src/assemble/cosmicos.js)

add_custom_target(wav DEPENDS ${CMAKE_BINARY_DIR}/index.wav)

##############################################################################
##
## Convert message to an iconic .html
##

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/index.html
  COMMAND ${CMAKE_BINARY_DIR}/bin/cosmsg.js text -p 0 -P -2 -v ${COSMIC_VOCAB} -w -nc
    > ${CMAKE_BINARY_DIR}/index.html
  WORKING_DIRECTORY ${WORK}
  DEPENDS
  ${COSMIC_VOCAB}
  ${CMAKE_BINARY_DIR}/index.json
  ${WORK}/CosmicAudio.js
  ${CMAKE_SOURCE_DIR}/src/assemble/cosmicos.js)

add_custom_target(html DEPENDS ${CMAKE_BINARY_DIR}/index.html)

# TODO: replace glob with file list
file(GLOB ts_files ${CMAKE_SOURCE_DIR}/src/**/*.ts)
add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/js/src/cosmicos/FourSymbolCodecV2.js
  COMMAND ${TSC} ${CMAKE_SOURCE_DIR}/src/cosmicos/FourSymbolCodecV2.ts
    ${CMAKE_SOURCE_DIR}/src/cosmicos/GlyphCode.ts
    ${CMAKE_SOURCE_DIR}/src/cosmicos/Rename.ts
    ${CMAKE_SOURCE_DIR}/src/cmd/cosh.ts
    --outDir ${CMAKE_BINARY_DIR}/js/
    --target esnext --module commonjs --lib esnext --resolveJsonModule --moduleResolution node
    DEPENDS ${ts_files} ${CMAKE_SOURCE_DIR}/msg/names.json)

add_custom_target(costs DEPENDS ${CMAKE_BINARY_DIR}/js/src/cosmicos/FourSymbolCodecV2.js)

##############################################################################
##
## Make a toy command-line cosmicos repl called cosh
##

add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/bin/cosh.js
  COMMAND
    ${CMAKE_COMMAND} -E env COSMIC_VARIANT=${COSMIC_VARIANT}
    ${WEBPACK} --config ${CMAKE_SOURCE_DIR}/src/webpack.config.js
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  DEPENDS ${CMAKE_BINARY_DIR}/js/src/cosmicos/FourSymbolCodecV2.js jshelpers)

add_custom_target(bundle DEPENDS ${CMAKE_BINARY_DIR}/bin/cosh.js)
add_custom_target(cli ALL DEPENDS ${CMAKE_BINARY_DIR}/bin/cosh.js)

