#!/bin/bash

set -e

which cmake || {
    echo "CMake not found.  Please install."
    exit 1
}

which make || {
    echo "make not found.  Please install."
    exit 1
}

mkdir -p build
cd build
cmake ..
make
