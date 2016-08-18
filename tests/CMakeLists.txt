set(WORK ${CMAKE_CURRENT_BINARY_DIR})
set(SRC1 ${CMAKE_SOURCE_DIR}/transform)
set(SRC2 ${CMAKE_SOURCE_DIR}/tests)

add_custom_command(OUTPUT ${WORK}/test.js
  COMMAND ${HAXE} -js test.js -main Main -cp ${SRC1} -cp ${SRC2}
  WORKING_DIRECTORY ${WORK}
  DEPENDS
    ${SRC2}/EvaluateTest.hx
    ${SRC2}/FourSymbolTest.hx
    ${SRC2}/Main.hx
    ${SRC2}/NormalizeTest.hx
    ${SRC2}/ParseTest.hx
    ${SRC2}/TranslateTest.hx
    ${SRC2}/UnflattenTest.hx
    ${CMAKE_BINARY_DIR}/transform/CosmicEval.js)

foreach(test ParseTest NormalizeTest UnflattenTest TranslateTest FourSymbolTest EvaluateTest)
  add_test(NAME ${test} COMMAND ${NODE} ${WORK}/test.js ${test})
endforeach()

add_custom_target(harness ALL DEPENDS
  ${WORK}/test.js
  jshelpers
)
