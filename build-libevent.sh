#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

EXT=libevent

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS=""

case $TCVER in
        64-14 ) DEPS="$DEPS openssl-1.1.1-dev" ;;
        32-14 ) DEPS="$DEPS openssl-1.1.1-dev" ;;
        64-13 ) DEPS="$DEPS openssl-1.1.1-dev" ;;
        32-13 ) DEPS="$DEPS openssl-1.1.1-dev" ;;
        64-12 ) DEPS="$DEPS openssl-1.1.1-dev" ;;
        32-12 ) DEPS="$DEPS openssl-1.1.1-dev" ;;
        64-11 ) DEPS="$DEPS openssl-1.1.1-dev" ;;
        32-11 ) DEPS="$DEPS openssl-1.1.1-dev" ;;
        64-10 ) DEPS="$DEPS openssl-1.1.1-dev" ;;
        32-10 ) DEPS="$DEPS openssl-1.1.1-dev" ;;
        * ) DEPS="$DEPS openssl-dev" ;;
esac

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh
. $MEDIR/phase-default-config.sh
. $MEDIR/phase-default-make.sh
. $MEDIR/phase-make-install-dev.sh
. $MEDIR/phase-default-move-dev.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

