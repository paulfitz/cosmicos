
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
set(SRC ${CMAKE_SOURCE_DIR}/transform)
set(MSG ${CMAKE_SOURCE_DIR}/src)

add_custom_command(OUTPUT ${WORK}/CosmicAudio.js
  COMMAND ${HAXE} -js CosmicAudio.js -main cosmicos.Sound -cp ${SRC}
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${SRC}/cosmicos/Sound.hx)

add_custom_command(OUTPUT ${WORK}/CosmicEval.js
  COMMAND ${HAXE} -js CosmicEval.js -main cosmicos.Evaluate -cp ${SRC}
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${SRC}/cosmicos/Evaluate.hx
  ${SRC}/cosmicos/Parse.hx
  ${SRC}/cosmicos/Vocab.hx
  ${SRC}/cosmicos/Memory.hx
  ${SRC}/cosmicos/ManuscriptStyle.hx
)

add_custom_command(OUTPUT ${WORK}/SpiderScrawl.js
  COMMAND ${HAXE} -js SpiderScrawl.js -main cosmicos.SpiderScrawl -cp ${SRC}
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${SRC}/cosmicos/SpiderScrawl.hx)

add_custom_command(OUTPUT ${WORK}/OghamStyle.js
  COMMAND ${HAXE} -js OghamStyle.js -main cosmicos.OghamStyle -cp ${SRC}
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${SRC}/cosmicos/OghamStyle.hx)

add_custom_target(jshelpers ALL DEPENDS 
  ${WORK}/CosmicAudio.js
  ${WORK}/CosmicEval.js
  ${WORK}/SpiderScrawl.js
  ${WORK}/OghamStyle.js
)



##############################################################################
##
## Add targets for message parts
##

# we expect to get a variable COSMIC_DEPENDS that lists all parts
include(${CMAKE_SOURCE_DIR}/src/README.cmake)

get_target_property(UnlessDriverLoc UnlessDriver JAR_FILE)
get_target_property(FritzifierLoc Fritzifier JAR_FILE)
FILE(WRITE ${WORK}/setup.cmake "
  set(base \"${CMAKE_SOURCE_DIR}/src\")
  set(out_dir \"${CMAKE_CURRENT_BINARY_DIR}\")
  set(JAVA_EXE \"${Java_JAVA_EXECUTABLE}\")
  set(JAVAC_EXE \"${Java_JAVAC_EXECUTABLE}\")
  set(UNLESS \"${UnlessDriverLoc}\")
  set(ENCODER \"${FritzifierLoc}\")
  set(BCEL \"${BCEL_JAR}\")
  set(NODE \"${NODE}\")
")

set(ACTIVE_DEPENDS)
set(ACTIVE_DEPENDS_SHORT "")
foreach(depend ${COSMIC_DEPENDS})
  foreach(ext pl scm gate java js)
    if(EXISTS ${MSG}/${depend}.${ext})
      add_custom_command(OUTPUT ${WORK}/${depend}.ftz
	COMMAND ${CMAKE_COMMAND} 
	"-Din:STRING=${depend}.${ext}" 
	"-Dout:STRING=${depend}.ftz"
	"-Dname:STRING=${depend}"
	-P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/convert_${ext}.cmake
	WORKING_DIRECTORY ${WORK}
	DEPENDS ${MSG}/${depend}.${ext} UnlessDriver Fritzifier
	${CMAKE_CURRENT_SOURCE_DIR}/cmake/convert_${ext}.cmake)
      list(APPEND ACTIVE_DEPENDS ${WORK}/${depend}.ftz)
      set(ACTIVE_DEPENDS_SHORT "${ACTIVE_DEPENDS_SHORT} ${depend}")
    endif()
  endforeach()
endforeach()

# assem.txt contains a concatenation of all message parts, in
# original textual form
add_custom_command(OUTPUT ${WORK}/assem.txt
  COMMAND ${CMAKE_COMMAND}
  "-Din:STRING=${ACTIVE_DEPENDS_SHORT}" 
  "-Dout:STRING=assem.txt"
  -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/assemble.cmake
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${ACTIVE_DEPENDS} ${CMAKE_CURRENT_SOURCE_DIR}/cmake/assemble.cmake)

# assem.json is a structured version of assem.txt, but still in original form
add_custom_command(OUTPUT ${WORK}/assem.json
  COMMAND ${NODE} ${CMAKE_SOURCE_DIR}/transform/assemble/assemble2json.js ${WORK}/assem.txt
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${WORK}/assem.txt)

# primer.json is a numeric version of the message, for self-references.
# Note that any lines relying on self-evaluation are inaccurate.
# It is important to not refer to such lines, in order to avoid
# circularity.  Ssh.
add_custom_command(OUTPUT ${WORK}/primer.json
  COMMAND ${CMAKE_COMMAND} 
  "-Din:STRING=${CMAKE_SOURCE_DIR}/transform/assemble/primer.js" 
  "-Dnargs:STRING=${WORK}/assem.json"
  "-Dlog:STRING=make-primer"
  -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/node.cmake
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${WORK}/assem.json
  ${WORK}/CosmicEval.js
  ${CMAKE_SOURCE_DIR}/transform/assemble/primer.js)

# assem2.json is assem.json but marked up also with message fragments
# in final form
add_custom_command(OUTPUT ${WORK}/assem2.json
  COMMAND ${CMAKE_COMMAND} 
  "-Din:STRING=${CMAKE_SOURCE_DIR}/transform/assemble/evaluate.js" 
  "-Dnargs:STRING="
  "-Dlog:STRING=make-assem2"
  -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/node.cmake
  COMMAND ${CMAKE_COMMAND} -E copy ${WORK}/assem2.json ${CMAKE_BINARY_DIR}/index.json
  COMMAND ${CMAKE_COMMAND} -E copy ${WORK}/q.txt ${CMAKE_BINARY_DIR}/index.txt
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${WORK}/assem.json
  ${WORK}/primer.json
  ${WORK}/CosmicEval.js
  ${CMAKE_SOURCE_DIR}/transform/assemble/evaluate.js)

add_custom_target(assem ALL DEPENDS ${WORK}/assem2.json)


##############################################################################
##
## Add optional targets (not in default build) for stats
##

# scan the active vocabulary
add_custom_command(OUTPUT ${WORK}/vocab.json
  COMMAND ${CMAKE_COMMAND} 
  "-Din:STRING=${CMAKE_SOURCE_DIR}/transform/assemble/vocab.js" 
  "-Dnargs:STRING=${WORK}/assem.json"
  "-Dlog:STRING=make-vocab"
  -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/node.cmake
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${WORK}/assem.json
  ${WORK}/CosmicEval.js
  ${CMAKE_SOURCE_DIR}/transform/assemble/vocab.js)

add_custom_target(vocab DEPENDS ${WORK}/vocab.json)


##############################################################################
##
## Make a toy command-line cosmicos repl called cosh
##

make_directory(${CMAKE_BINARY_DIR}/bin)
make_directory(${CMAKE_BINARY_DIR}/lib)
set(PERM_CMD)
if (UNIX)
  set(PERM_CMD COMMAND chmod +x ${CMAKE_BINARY_DIR}/bin/cosh.js)
endif()
add_custom_command(OUTPUT ${CMAKE_BINARY_DIR}/bin/cosh.js
  COMMAND ${CMAKE_COMMAND} -E copy ${WORK}/CosmicEval.js ${CMAKE_BINARY_DIR}/lib/cosh.js
  COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/tools/repl/repl.js ${CMAKE_BINARY_DIR}/bin/cosh.js
  ${PERM_CMD}
  WORKING_DIRECTORY ${WORK}
  DEPENDS ${WORK}/CosmicEval.js
  ${CMAKE_SOURCE_DIR}/tools/repl/repl.js)
add_custom_target(cli ALL DEPENDS ${CMAKE_BINARY_DIR}/bin/cosh.js)


##############################################################################
##
## Add a little utility for scanning message
##

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/assemble/cosmicos ${CMAKE_BINARY_DIR}/bin/cosmsg.js @ONLY)

