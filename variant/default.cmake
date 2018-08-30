# we expect to get a variable COSMIC_DEPENDS that lists all parts
include(${CMAKE_SOURCE_DIR}/msg/README.cmake)

# Flag controlling whether the "|" symbol for flattening messages can be
# encoded (if false), or (if false) should be expanded to nested parens.
set(COSMIC_USE_FLATTENER true)
