#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-make-funcs.sh

sudo chown -R root.staff /usr/local/tce.installed
sudo chmod -R 775 /usr/local/tce.installed

## tier 1

LIBAIOVER=0.3.113
LIBAIODEB=2

cd $BUILD
sudo rm -rf $BUILD/libaio-$LIBAIOVER
tar xf $SOURCE/libaio_$LIBAIOVER.orig.tar.gz
cd $BUILD/libaio-$LIBAIOVER
tar xf $SOURCE/libaio_$LIBAIOVER-$LIBAIODEB.debian.tar.xz
echo -e "\n=====  build-libaio.sh =====\n"
$PROD/build-libaio.sh
copy_tcz libaio

