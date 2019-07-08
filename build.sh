#!/bin/bash

set -e
set -x

builder=tmp$(uuidgen)
 
docker build -t "$builder" . 1>&2

docker run --rm \
			 -v /var/run/docker.sock:/var/run/docker.sock \
			 -v $PWD/.env:/build/.env \
			 "$builder" \
			 "$@"

