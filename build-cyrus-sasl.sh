#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

EXT=cyrus-sasl

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="openldap-dev gdbm-dev sqlite3-dev automake libtool-dev groff"

case $TCVER in
        64-14 ) PGVER=15; SSLVER=-1.1.1; MDBVER=10.6 ;;
        32-14 ) PGVER=15; SSLVER=-1.1.1; MDBVER=10.6 ;;
        64-13 ) PGVER=14; SSLVER=-1.1.1; MDBVER=10.6 ;;
        32-13 ) PGVER=14; SSLVER=-1.1.1; MDBVER=10.6 ;;
        64-12 ) PGVER=13; SSLVER=-1.1.1; MDBVER=10.5 ;;
        32-12 ) PGVER=13; SSLVER=-1.1.1; MDBVER=10.5 ;;
        64-11 ) PGVER=12; SSLVER=-1.1.1; MDBVER=10.4 ;;
        32-11 ) PGVER=12; SSLVER=-1.1.1; MDBVER=10.4 ;;
        64-10 ) PGVER=12; SSLVER=-1.1.1; MDBVER=10.4 ;;
        32-10 ) PGVER=12; SSLVER=-1.1.1; MDBVER=10.4 ;;
        * ) PGVER=11; SSLVER=""; MDBVER=10.1 ;;
esac
DEPS="$DEPS openssl$SSLVER-dev postgresql-$PGVER-dev mariadb-$MDBVER-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

#./autogen.sh \
./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--sysconfdir=/usr/local/etc/sasl2 \
	--with-plugindir=/usr/local/lib/sasl2 \
	--with-configdir=/usr/local/etc/sasl2 \
	--with-saslauthd=/var/run/saslauthd \
	--enable-shared \
	--disable-static \
	--with-devrandom=/dev/urandom \
	--with-openssl \
	--with-gdbm \
	--with-dblib=gdbm \
	--with-dbpath=/usr/local/etc/sasl2/db \
	--enable-sql \
	--with-mysql=/usr/local/mysql \
	--with-pgsql=/usr/local/pgsql$PGVER \
	--with-sqlite3=/usr/local \
	--with-ldap \
	--enable-ldapdb \
	--with-pam=no \
	|| exit

find . -name Makefile -type f -exec sed -i 's/-g -O2//g' {} \;
find . -name Makefile -type f -exec sed -i -e 's#/usr/local/mysql/include/mysql #/usr/local/mysql/include #' {} \;
find . -name Makefile -type f -exec sed -i -e 's#/usr/local/mysql #/usr/local/mysql/include #' {} \;

make sasldir=/usr/local/lib/sasl2 || exit
make sasldir=/usr/local/lib/sasl2 install DESTDIR=$TCZ-dev

mkdir -p $TCZ/usr/local/etc/sasl2/db
mkdir -p $TCZ/usr/local/lib/sasl2

mv $TCZ-dev/usr/local/sbin $TCZ/usr/local
mv $TCZ-dev/usr/local/lib/*.so* $TCZ/usr/local/lib
mv $TCZ-dev/usr/local/lib/sasl2/*.so* $TCZ/usr/local/lib/sasl2

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

