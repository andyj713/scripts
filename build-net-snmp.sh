#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

EXT=net-snmp

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="libtool-dev cmake readline-dev liblzma-dev perl5 
 libpcap-dev libpci-dev ncursesw-dev ncursesw-terminfo
 pcre-dev"
# perl5 libxml2-python glib2-python python3.6-dev python3.6-setuptools

case $TCVER in
        64-15 ) DEPS="$DEPS openssl-dev mariadb-11.2-dev" ;;
        32-15 ) DEPS="$DEPS openssl-dev mariadb-11.2-dev" ;;
        64-14 ) DEPS="$DEPS openssl-dev mariadb-11.2-dev" ;;
        32-14 ) DEPS="$DEPS openssl-dev mariadb-11.2-dev" ;;
        64-13 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.6-dev" ;;
        32-13 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.6-dev" ;;
        64-12 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.5-dev" ;;
        32-12 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.5-dev" ;;
        64-11 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.4-dev" ;;
        32-11 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.4-dev" ;;
        64-10 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.4-dev" ;;
        32-10 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.4-dev" ;;
        * ) DEPS="$DEPS openssl-dev mariadb-11.2-dev" ;;
esac

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

echo $PATH | grep -q mysql || export PATH=$PATH:/usr/local/mysql/bin

#sudo ln -s $(which python3) /usr/local/bin/python
#	--with-python-modules \
#	--without-kmem-usage \

export CFLAGS="$CFLAGS -DHAVE_MYSQL_INIT=1 -DHAVE_MARIADB_LOAD_DEFAULTS=1"

./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--disable-embedded-perl \
	--with-mysql \
	--with-perl-modules \
	--with-openssl=/usr/local \
	--with-defaults \
	--without-rpm \
	--with-install-prefix=$TCZ \
	|| exit

sed -i -e "/PYMAKE) install/s#basedir#root=$TCZ --basedir#" Makefile

# configure option --without-kmem-usage is broken
#sed -i -e '/define HAVE_KMEM/s%#define HAVE_KMEM "/dev/kmem"%/* #undef HAVE_KMEM */%' include/net-snmp/net-snmp-config.h

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh

chmod -R ug+w $TCZ

mkdir -p $TCZ-dev/usr/local/bin
mkdir -p $TCZ-dev/usr/local/lib
mkdir -p $TCZ-dev/usr/local/share

mv $TCZ/usr/local/include $TCZ-dev/usr/local
mv $TCZ/usr/local/lib/*.a $TCZ-dev/usr/local/lib
mv $TCZ/usr/local/lib/*.la $TCZ-dev/usr/local/lib
#rm $TCZ/usr/local/lib/*.a
#rm $TCZ/usr/local/lib/*.la
mv $TCZ/usr/local/share/man $TCZ-dev/usr/local/share
mv $TCZ/usr/local/bin/net-snmp-config $TCZ-dev/usr/local/bin/net-snmp-config

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

