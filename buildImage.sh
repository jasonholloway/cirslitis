#!/bin/sh

set -x
set -e

name=cirslitis

main() {
	loadEnv
	prepFile haproxy.cfg
	buildVhd
	pipeOut
}

loadEnv() {
	[ -f .env ] && . .env;
}

prepFile() {
	file="$1"
	data=$(cat "$file")
	echo "$data" | envsubst "$data" > "$file"
}

buildVhd() {
	linuxkit build \
					-format raw-bios \
					-disable-content-trust \
					"${name}.yml" \
					1>&2

	qemu-img convert \
					-O vpc \
					-o subformat=fixed,force_size \
					"${name}-bios.img" \
					"${name}.vhd" \
					1>&2
}

pipeOut() {
	cat "${name}.vhd"
}

main
