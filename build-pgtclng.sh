#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

EXT=pgtclng

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="tcl8.6-dev"
case $TCVER in
        64-15 ) PGVER=16 ;;
        32-15 ) PGVER=16 ;;
        64-14 ) PGVER=15 ;;
        32-14 ) PGVER=15 ;;
        64-13 ) PGVER=14 ;;
        32-13 ) PGVER=14 ;;
        64-12 ) PGVER=13 ;;
        32-12 ) PGVER=13 ;;
        64-11 ) PGVER=12 ;;
        32-11 ) PGVER=12 ;;
        64-10 ) PGVER=12 ;;
        32-10 ) PGVER=12 ;;
        * ) PGVER=11 ;;
esac
DEPS="$DEPS postgresql-$PGVER-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

./configure \
	--with-tcl=/usr/local/lib \
	--with-tclinclude=/usr/local/include \
	--with-postgres-include=/usr/local/pgsql$PGVER/include \
	--with-postgres-lib=/usr/local/pgsql$PGVER/lib \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

