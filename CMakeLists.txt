cmake_minimum_required(VERSION 2.8)

project(cosmicos NONE)

add_subdirectory(tools)
add_subdirectory(src)

enable_testing()
add_subdirectory(tests)
