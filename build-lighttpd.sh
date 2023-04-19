#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

EXT=lighttpd

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="gdbm-dev cyrus-sasl-dev
	attr-dev openldap-dev libxml2-dev sqlite3-dev"

case $TCVER in
        64-14 ) PGVER=15; SSLVER=-1.1.1; MDBVER=10.6 ; PCREVER=21032 ;;
        32-14 ) PGVER=15; SSLVER=-1.1.1; MDBVER=10.6 ; PCREVER=2 ;;
        64-13 ) PGVER=14; SSLVER=-1.1.1; MDBVER=10.6 ; PCREVER=21032 ;;
        32-13 ) PGVER=14; SSLVER=-1.1.1; MDBVER=10.6 ; PCREVER=2 ;;
        64-12 ) PGVER=13; SSLVER=-1.1.1; MDBVER=10.5 ;;
        32-12 ) PGVER=13; SSLVER=-1.1.1; MDBVER=10.5 ;;
        64-11 ) PGVER=12; SSLVER=-1.1.1; MDBVER=10.4 ;;
        32-11 ) PGVER=12; SSLVER=-1.1.1; MDBVER=10.4 ;;
        64-10 ) PGVER=12; SSLVER=-1.1.1; MDBVER=10.4 ;;
        32-10 ) PGVER=12; SSLVER=-1.1.1; MDBVER=10.4 ;;
        * ) PGVER=11; SSLVER=""; MDBVER=10.1 ;;
esac
DEPS="$DEPS openssl$SSLVER-dev postgresql-$PGVER-dev mariadb-$MDBVER-dev pcre$PCREVER-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

./configure \
	--libdir=/usr/local/lib/lighttpd \
	--sysconfdir=/usr/local/etc/lighttpd \
	--localstatedir=/var \
	--enable-shared \
	--with-openssl \
	--with-pcre2 \
	--with-zlib \
	--with-zstd \
	--with-bzip2 \
	--with-mysql=/usr/local/mysql/bin/mysql_config \
	--with-pgsql=/usr/local/pgsql$PGVER/bin/pg_config \
	--with-sasl \
	--with-ldap \
	--with-attr \
	--with-webdav-props \
	--with-webdav-locks \
	--with-libxml \
	--with-sqlite \
	--with-uuid \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

