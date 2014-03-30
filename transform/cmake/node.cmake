include(setup.cmake)
set(ENV{NODE_PATH} "${out_dir}")
message(STATUS "set node path to $ENV{NODE_PATH}")
execute_process(COMMAND ${NODE} ${in} ${args})
