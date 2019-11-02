#!/bin/bash

set -e

hash docker 2>/dev/null || {
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

# start a container in the background, just to make builds more responsive
docker ps -f name=cosmicos_build | grep -q cosmicos || {
  docker run --rm --name cosmicos_build -v $PWD:/cosmicos paulfitz/cosmicos_builder src/prepare_node.sh
  docker run -dit --rm $args --name cosmicos_build -v $PWD:/cosmicos -v $PWD/node_modules_docker:/cosmicos/node_modules paulfitz/cosmicos_builder /bin/bash
}

# run our actual build command, finally
if [[ "$1" = "run" ]]; then
  shift
  docker exec -e VERBOSE=$VERBOSE cosmicos_build "$@"
elif [[ "$1" = "console" ]]; then
  shift
  docker exec -it -e VERBOSE=$VERBOSE cosmicos_build /bin/bash
elif [[ "$1" = "mocha" ]]; then
  docker exec -e VERBOSE=$VERBOSE cosmicos_build node_modules/.bin/mocha tests/test_basics.ts
else
  docker exec -e VERBOSE=$VERBOSE cosmicos_build src/make_without_docker.sh "$@"
fi
