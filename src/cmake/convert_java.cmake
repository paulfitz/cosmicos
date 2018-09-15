include(setup.cmake)

file(READ ${base}/${in} CONTENTS)
if("${CONTENTS}" MATCHES "STUB: ([^*]+) \\*")
  file(WRITE ${out} "${CMAKE_MATCH_1}\n")
else()
  execute_process(COMMAND ${JAVAC_EXE} -source 1.4 -cp "." -d ${out_dir} ${in} WORKING_DIRECTORY ${base})
  execute_process(COMMAND ${JAVA_EXE} -cp ".:${BCEL}:${ENCODER}" Fritzifier ${name} ${out}.text WORKING_DIRECTORY ${out_dir})
  execute_process(COMMAND perl ${base}/../src/filter/java-comment.pl ${out}.text ${base}/${name}.java OUTPUT_FILE ${out}) 
endif()
