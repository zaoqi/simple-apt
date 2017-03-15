#!/bin/sh
#Simple APT
#Copyright (C) 2017  zaoqi

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU Affero General Public License as published
#by the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Affero General Public License for more details.

#You should have received a copy of the GNU Affero General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
getpidSh="$(mktemp)"
echo '#!/bin/sh
echo $PPID'>$getpidSh
chmod a+x $getpidSh
getpid() {
	$getpidSh
}
testInfo() {
	cat >> _TEST
}
pid="$(getpid)"
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
	debinfo "$*" | grep '^Depends' | sed 's/^Depends: \(.*\)$/\1/' | sed 's/([^)]*)//g' | sed 's/ *, */ /g' | sed 's/ *| */ /g'
}
#参数：$dvd
packages() {
	for f in "$*/dists/jessie"/*/binary-armel/Packages.gz ;do
		gzip -dc "$f"
	done
}
#参数：$dvd 包名
package() {
	packages "$1" | grep -A 100 '^Package: '"$2"'$' | untilNN
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
getdebRaw() {
	package "$1" "$2" | grep '^Filename' | sed 's/^Filename: \(.*\)$/\1/g'
}
#参数：$dvd 包名
getdeb() {
	local d=$(getdebRaw "$1" "$2")
	if [ "$d" = "" ] ;then
		package "$1" "$2" | testInfo
		echo "NoFilename-$1-$2" | testInfo
		return
	fi
	echo -n "$1/"
	echo $d
}
#参数：$dvd 包名
packagedep() {
	local t="$(mktemp)"
	getdeb "$1" "$2">$t
	local p="$(cat $t)"
	if [ "$p" = "" ] ;then
		return
	fi
	local d=$(undeb "$p")
	rm "$t" 1>&2 || error
	debdep "$d"
	rm -rfv "$d" 1>&2 || error
}
error() {
	echo "ERROR" 1>&2
	echo "ERROR" | testInfo
	kill $pid
	exit 1
}
#参数：$dvd 包名
#下载包和所有依赖到当前目录
downloaddeb() {
	local t="$(mktemp)"
	getdeb "$1" "$2">$t
	local p="$(cat $t)"
	basename "$p">$t
	if [ "$p" = "" ] || [ -f "$(cat $t)" ] ;then
		return
	fi
	rm "$t" 1>&2 || error
	cp "$p" ./
	for dp in $(packagedep "$1" "$2") ;do
		downloaddeb "$1" "$dp"
	done
}
#debdep $(undeb "$pool/main/a/apt"/apt_*_armel.deb)
downloaddeb "$dvd" apt
