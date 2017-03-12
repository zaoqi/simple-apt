#!/bin/sh
dvd="$1"
pool="$1/pool"
if [ ! -d "$pool" ] ;then
	echo "使用方法：apt.sh <Debian DVD 目录绝对路径>" 1>&2
	exit 1
fi
#参数：deb文件
undeb() {
	cd "$(mktemp -d)"
	ar -xv "$*" 1>&2 || error
	pwd
	cd - >/dev/null
}
#参数：undeb得到的
debinfo() {
	cd "$(mktemp -d)"
	tar -xvf "$*"/control.tar.* 1>&2 || error
	cat control
	cd - >/dev/null
	rm -rfv $OLDPWD 1>&2 || error
}
#参数：undeb得到的
debdep() {
	debinfo "$*" | grep Depends | sed 's/Depends: \(.*\)/\1/' | sed 's/([^)]*)//g' | sed 's/ *, */ /g'
}
#参数：$dvd
packages() {
	for f in "$*/dists/jessie"/*/binary-armel/Packages.gz ;do
		gzip -dc "$f" || error
	done
}
#参数：$dvd 包名
package() {
	packages "$1" | grep -A 100 'Package: '"$2" | untilNN
}
untilNN() {
	while read line ;do
		if [ "$line" = "" ] ;then
			return
		else
			echo "$line"
		fi
	done
}
#参数：$dvd 包名
getdeb() {
	echo -n "$1/"
	package "$1" "$2" | grep Filename | sed 's/Filename: \(.*\)/\1/g'
}
error() {
	echo "ERROR" 1>&2
	exit 1
}
#debdep $(undeb "$pool/main/a/apt"/apt_*_armel.deb)
getdeb "$dvd" python-wstools
