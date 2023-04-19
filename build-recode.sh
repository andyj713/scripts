#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

EXT=recode

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="texinfo autoconf"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

sh ./after-patch.sh
sed -i -e 's/ bool ignore : 2;/ bool ignore : 1;/' src/recodext.h

ACLOCAL=aclocal CXXCPP=/usr/local/bin/cpp sh ./configure \
	--disable-rpath \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh

mkdir -p $TCZ/usr/local/lib
mkdir -p $TCZ/usr/local/share
mv $TCZ-dev/usr/local/bin $TCZ/usr/local
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/share/locale $TCZ/usr/local/share

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

