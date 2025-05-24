#!/bin/bash
# (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
# Modifications Copyright (c) 2025 Kagan Dikmen
# See LICENSE and NOTICE for details

if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
	echo "exctract_hex <input elf file> <imem hex file> <dmem hex file>"
	exit 1
fi

if [ -z "$TOOLCHAIN_PREFIX" ]; then
	TOOLCHAIN_PREFIX=riscv32-unknown-elf
fi;

$TOOLCHAIN_PREFIX-objdump -d -w $1 | sed '1,5d' | awk '!/:$/ { print $2; }' | sed '/^$/d' > $2; \
: > "$3" \
test -z "$($TOOLCHAIN_PREFIX-readelf -l $1 | grep .data)" || \
	$TOOLCHAIN_PREFIX-objdump -s -j .data $1 | sed '1,4d' | \
	awk '!/:$/ { for (i = 2; i < 6; i++) print $i; }' | sed '/^$/d' > $3;

exit 0

