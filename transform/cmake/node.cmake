include(setup.cmake)
set(ENV{NODE_PATH} "${out_dir}:$ENV{NODE_PATH}")
execute_process(COMMAND ${NODE} ${in} ${nargs} OUTPUT_FILE ${out_dir}/${log}.txt)
