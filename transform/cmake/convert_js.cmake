include(setup.cmake)
set(ENV{NODE_PATH} ${base})
execute_process(COMMAND node ${base}/${in} OUTPUT_FILE ${out})
