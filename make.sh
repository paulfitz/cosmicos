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

if [[ -n "$UID" && -n "$USER" ]]; then
    # run docker as current user for convenience
    args="-u=$UID:$(id -g $USER)"
fi

docker run -it --rm $args -v $PWD:/cosmicos paulfitz/cosmicos_builder tools/make_without_docker.sh "$@"
