include(setup.cmake)
execute_process(COMMAND perl ${base}/../src/filter/wrap.pl ${in} OUTPUT_FILE ${out} RESULT_VARIABLE result)

if (NOT ${result} EQUAL 0)
  if (EXISTS ${out})
    file(REMOVE ${out})
  endif()
  message(FATAL_ERROR "wrap.cmake returned ${result}")
endif()
