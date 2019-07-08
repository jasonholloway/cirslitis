#!/bin/bash

set -e
set -x

name=cirslitis
builder=tmp$(uuidgen)
 
docker build -t "$builder" . 1>&2

mkdir -p out

docker run --rm \
			 --env-file ./.env \
			 -v /var/run/docker.sock:/var/run/docker.sock \
			 "$builder" \
			 ./buildImage.sh "$name" \
			 > out/"$name".vhd

