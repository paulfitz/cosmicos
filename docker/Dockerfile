# This creates an image that is good enough for building CosmicOS

FROM ubuntu:18.04

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends libbcel-java openjdk-8-jdk libgd-perl nodejs \
    haxe cmake make && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /cosmicos
