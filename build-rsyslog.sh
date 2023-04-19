#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

EXT=rsyslog

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="jemalloc-dev pcre-dev net-snmp-dev curl-dev libgcrypt-dev autoconf automake
 iproute2 libestr-dev libfastjson-dev liblognorm-dev liblogging-dev libnet-dev libnet"

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

echo $PATH | grep -q pgsql || export PATH=$PATH:/usr/local/mysql/bin:/usr/local/pgsql$PGVER/bin:/usr/local/oracle

sed -i -e 's#"/etc/rsyslog.conf"#"/usr/local/etc/rsyslog.conf"#' tools/rsyslogd.c

autoreconf --verbose --force --install || exit 1

#./autogen.sh \

#sed -i -e 's/mysql_init()/mysql_init(NULL)/' configure
#sed -i -e 's#\$MYSQL_CONFIG --libs#$MYSQL_CONFIG --libs | sed "s%/tmp/tcloop/mariadb-10.3-dev%%g"#' configure
#sed -i -e 's#\$MYSQL_CONFIG --cflags#$MYSQL_CONFIG --cflags | sed "s%/tmp/tcloop/mariadb-10.3-dev%%g"#' configure

./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--sysconfdir=/usr/local/etc \
	--enable-shared \
	--enable-regexp \
	--enable-fmhash \
	--enable-klog \
	--enable-kmsg \
	--disable-libsystemd \
	--disable-debug \
	--disable-imjournal \
	--enable-inet \
	--enable-jemalloc \
	--enable-diagtools \
	--enable-usertools \
	--enable-mysql \
	--enable-pgsql \
	--enable-snmp \
	--enable-uuid \
	--enable-omhttp \
	--enable-elasticsearch \
	--enable-openssl \
	--enable-gnutls \
	--enable-libgcrypt \
	--enable-libzstd \
	--enable-rsyslogrt \
	--enable-rsyslogd \
	--enable-mmnormalize \
	--enable-mmjsonparse \
	--enable-mmaudit \
	--enable-mmanon \
	--enable-mmutf8fix \
	--enable-mmcount \
	--enable-mmsequence \
	--enable-mmfields \
	--enable-imfile \
	--enable-imptcp \
	--enable-impstats \
	--enable-omprog \
	--enable-omudpspoof \
	--enable-omstdout \
	--disable-omjournal \
	--enable-pmlastmsg \
	--enable-pmcisconames \
	--enable-pmciscoios \
	--enable-pmnormalize \
	--enable-omruleset \
	--enable-mmsnmptrapd \
	--enable-omhttpfs \
	--enable-omtcl \
	--disable-generate-man-pages \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh
. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

