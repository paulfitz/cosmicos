include(setup.cmake)
set(ENV{NODE_PATH} "${out_dir}:${path}:$ENV{NODE_PATH}")
execute_process(COMMAND ${TSNODE} ${in} ${nargs} OUTPUT_FILE ${out_dir}/${log}.txt)
