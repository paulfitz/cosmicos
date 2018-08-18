#!/bin/bash

set -e

which docker || {
    echo "Docker not found.  Please install."
    exit 1
}

if [ -e build ]; then
    if [ ! -e build/docker_build.txt ]; then
        echo "Please remove build directory."
        exit 1
    fi
fi

mkdir -p build
touch build/docker_build.txt

docker run -it --rm -v $PWD:/cosmicos paulfitz/cosmicos_builder ./build.sh "$@"
