#!/bin/bash

# tag the image based on the enclosing directory name
BUILD_DIR=$(dirname $(readlink -f "$BASH_SOURCE"))
TAG_NAME=$(basename $(dirname $BUILD_DIR))

# only build the image if the tag name isn't listed as a docker image
# (this prevents Docker from rebuilding every time because of the 'ADD' command for ARM GCC)
DOCKER_IMAGES=$(docker image ls)
if [[ $DOCKER_IMAGES == *"$TAG_NAME"* ]]; then
  echo "Docker image '$TAG_NAME' already exists"
else
  echo "Need to build Docker image '$TAG_NAME'"
  docker build -t $TAG_NAME $BUILD_DIR
fi

# run the image with any provded arguments
docker run --mount type=bind,source="$(pwd)",target=/app $TAG_NAME "$@"