#!/bin/bash

set -x
set -e

name=cirslitis
commit=$(git rev-parse --short HEAD)

main() {
	loadEnv
	clean
	build
	copyOutput
}

loadEnv() {
	[[ -f ".env" ]] && source .env;
}

clean() {
	rm -rf build
}

build() {
	cp -R src build
	(envsubst < src/haproxy.cfg) > build/haproxy.cfg

	(cd build;
		linuxkit build -format qcow2-bios $name.yml;
		qemu-img convert \
						-O vpc -o subformat=fixed,force_size \
						$name.qcow2 \
						$name.vhd)

					#	-f qcow2 \
}

copyOutput() {
	mkdir -p out
	mv build/$name.vhd out/$name-$commit.vhd
#	clean
}

main
