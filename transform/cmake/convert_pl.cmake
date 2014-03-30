include(setup.cmake)
execute_process(COMMAND perl -I${base} ${base}/${in} OUTPUT_FILE ${out})
