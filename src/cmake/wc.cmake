include(setup.cmake)
execute_process(COMMAND perl -e "print(length(join('',<>)),'\n')" ${in} OUTPUT_FILE ${out} RESULT_VARIABLE result)

if (NOT ${result} EQUAL 0)
  if (EXISTS ${out})
    file(REMOVE ${out})
  endif()
  message(FATAL_ERROR "wc.cmake returned ${result}")
endif()
