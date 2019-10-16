#!/bin/bash

set -e

if [ ! -e node_modules_docker ]; then
  mv node_modules node_modules_host || echo ok
  echo "First time operation: installing node packages"
  npm install
  mv node_modules node_modules_docker
  mv node_modules_host node_modules || echo ok
fi
