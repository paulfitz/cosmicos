include(setup.cmake)

execute_process(COMMAND ${JAVA_EXE} -cp "${UNLESS}" UnlessDriver ${in} OUTPUT_FILE ${out_dir}/${out}.base WORKING_DIRECTORY ${base})
execute_process(COMMAND perl ${base}/../bin/drawgate-ppm.pl INPUT_FILE ${out}.base OUTPUT_FILE ${name}.ppm)
execute_process(COMMAND perl ${base}/../bin/drawgate-txt.pl INPUT_FILE ${out}.base OUTPUT_FILE ${out}.text)

file(READ ${out}.text CONTENTS)
string(TOLOWER "${name}" name_lc)
string(REGEX REPLACE "CIRCUIT_NAME" "${name_lc}" CONTENTS "${CONTENTS}")
file(WRITE ${out} "${CONTENTS}")
file(READ ${out}.base CONTENTS)
file(APPEND ${out} "${CONTENTS}")
