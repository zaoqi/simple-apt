#!/bin/sh
pool="$1/pool"
if [ ! -d "$pool" ] ;then
	echo "使用方法：apt.sh <Debian DVD 目录绝对路径>" 1>&2
	exit 1
fi
undeb() {
	cd $(mktemp -d)
	ar -xv "$1" 1>&2 || error
	pwd
	cd - >/dev/null
}
debinfo() {
	cd $(mktemp -d)
	tar -xvf "$1"/control.tar.* 1>&2 || error
	cat control
	cd - >/dev/null
	rm -rfv $OLDPWD 1>&2 || error
}
error() {
	echo "ERROR" 1>&2
	exit 1
}
debinfo $(undeb "$pool/main/a/apt"/apt_*_armel.deb)
