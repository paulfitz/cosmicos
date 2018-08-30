include(setup.cmake)
execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${base}/${in} ${out})
