#!/usr/bin/env bash
set -e

use_tag="glacsius/uvicorn-gunicorn-fastapi-docker-ubuntu:$NAME"

DOCKERFILE="$NAME"

if [ "$NAME" == "latest" ] ; then
    DOCKERFILE="python3"
fi

docker build -t "$use_tag" --file "./docker-images/${DOCKERFILE}.dockerfile" "./docker-images/"
