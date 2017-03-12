#!/bin/sh
d="$(mktemp -d)"
t="$(mktemp)"
cp -f "$*" $t
cd $d
ar -xv $t
cd -
tar -xvf $d/data.tar.*
rm -rfv $t $d
