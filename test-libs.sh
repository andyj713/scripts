#!/bin/sh
#


BASE=/mnt/sda1/lamp
SOURCE=$BASE/src
SCRIPTS=$BASE/scripts

test "$(uname -m)" = "x86_64" && export KBITS=64 || export KBITS=32
BUILD=$BASE$KBITS/build

PROD="$SCRIPTS"

#
#
#
build_dir(){
	EXT="$1"
	for a in $(find $BUILD -maxdepth 1 -type d -iname "$EXT*"); do
		SRC=$a
		break
	done
}

export TZ=UTC
export LD_LIBRARY_PATH=/usr/local/pgsql10/lib

for PKG in jemalloc libevent libfastjson libgd lighttpd Recode liblognorm; do
	build_dir $PKG
	cd $SRC
	echo $(pwd)
	make check 2>&1 | tee make-check-$PKG.log
done

tce-load -i postgresql-14 tcl8.6 msodbcsql oracle-12.2-client mariadb-10.6

for PKG in postgresql tcllib apr-util apr; do
	build_dir $PKG
	cd $SRC
	echo $(pwd)
	make check 2>&1 | tee make-check-$PKG.log
done

	
for PKG in tcludp net-snmp tls; do
	build_dir $PKG
	cd $SRC
	echo $(pwd)
	make test 2>&1 | tee make-test-$PKG.log
done
	

build_dir bind
cd $SRC
echo $(pwd)
sudo $SRC/bin/tests/system/ifconfig.sh up
make check 2>&1 | tee make-check-bind.log


build_dir tcl8.6
cd $SRC/unix
echo $(pwd)
make test 2>&1 | tee make-check-tcl.log


build_dir libaio
cd $SRC
echo $(pwd)
sudo make check 2>&1 | tee make-check-libaio.log


