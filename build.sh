#!/bin/bash

set -x

source .env

mkdir -p build && cd build

(envsubst < ../haproxy.cfg) > haproxy.cfg

linuxkit build -format vhd ../cirslitis.yml

