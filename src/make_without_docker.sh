#!/bin/bash

set -e

hash cmake 2>/dev/null || {
    echo "CMake not found.  Please install."
    exit 1
}

hash make 2>/dev/null || {
    echo "make not found.  Please install."
    exit 1
}

arg="$1"
message=${arg-:}
mkdir -p build
if [[ -e "variant/$message.cmake" ]]; then
    shift
    echo "$message" > build/last_message.txt
else
    message=""
fi

if [[ "$message" = "" ]]; then
    if [[ -e build/last_message.txt ]]; then
        message=`cat build/last_message.txt`
    fi
fi

if [[ "$message" = "" ]]; then
    echo "Do not know which message to build"
    exit 1
fi

echo "Working on message: $message"

mkdir -p build/$message
cd build/$message
if [ "$1" = "configure" ]; then
  ccmake ../..
else
  cmake -DCOSMIC_VARIANT=$message ../..
  make "$@" && echo "Result in build/$message"
fi
