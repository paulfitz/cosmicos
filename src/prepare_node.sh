#!/bin/bash

set -e

if [ ! -e node_modules_docker ]; then
  if [ -e node_modules ]; then
    mv node_modules node_modules_host
  fi
  echo "First time operation: installing node packages"
  npm install
  mv node_modules node_modules_docker
  if [ -e node_modules_host ]; then
    mv node_modules_host node_modules
  fi
fi
