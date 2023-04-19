#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

EXT=php7-pecl-sync

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="php7-dev automake"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

phpize

. $MEDIR/phase-default-config.sh
. $MEDIR/phase-default-make.sh

make install INSTALL_ROOT=$TCZ

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

