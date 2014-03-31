include(setup.cmake)
set(ENV{NODE_PATH} "${out_dir}")
execute_process(COMMAND ${NODE} ${in} ${nargs} OUTPUT_FILE ${out_dir}/${log}.txt)
