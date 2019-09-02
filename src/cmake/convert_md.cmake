include(setup.cmake)
file(READ ${base}/${in} FIN)
file(WRITE ${out} "[[[\n")
file(APPEND ${out} ${FIN})
file(APPEND ${out} "\n]]]\n")

#execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${base}/${in} ${out})
