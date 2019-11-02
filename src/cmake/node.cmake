include(setup.cmake)
set(ENV{NODE_PATH} "${out_dir}:${path}:$ENV{NODE_PATH}:${CMAKE_BINARY_DIR}/../js")
execute_process(COMMAND ${NODE} ${in} ${nargs} OUTPUT_FILE ${out_dir}/${log}.txt)
