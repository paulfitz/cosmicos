
find_package(Java REQUIRED)
include(UseJava)

find_jar(BCEL_JAR NAMES bcel)
if(NOT BCEL_JAR)
  message(FATAL_ERROR "could not find bcel.jar, please install libbcel-java or similar")
endif()
set(CMAKE_JAVA_INCLUDE_PATH ${BCEL_JAR} ${CMAKE_JAVA_INCLUDE_PATH})

add_jar(Fritzifier ${CMAKE_CURRENT_SOURCE_DIR}/Fritzifier.java ENTRY_POINT Fritzifier)

add_jar(UnlessDriver ${CMAKE_CURRENT_SOURCE_DIR}/UnlessDriver.java ENTRY_POINT UnlessDriver)
