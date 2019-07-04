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
		linuxkit build -format raw-efi $name.yml;
		qemu-img convert \
						-f raw \
						-O vpc -o subformat=fixed,force_size \
						$name-efi.img \
						$name.vhd)
}

copyOutput() {
	mkdir -p out
	mv build/$name.vhd out/$name-$commit.vhd
	clean
}

main
