#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

EXT=psqlodbc

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="postgresql-15-dev postgresql-15 unixODBC-dev unixODBC"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

./configure \
	--with-unixodbc \
	--with-libpq=/usr/local/pgsql15 \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

