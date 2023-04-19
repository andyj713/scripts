#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

EXT=net-snmp

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="libtool-dev cmake readline-dev pcre-dev liblzma-dev perl5 
 libpcap-dev libpci-dev ncursesw-dev ncursesw-terminfo"
# perl5 libxml2-python glib2-python python3.6-dev python3.6-setuptools

case $TCVER in
        64-14 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.6-dev" ;;
        32-14 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.6-dev" ;;
        64-13 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.6-dev" ;;
        32-13 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.6-dev" ;;
        64-12 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.5-dev" ;;
        32-12 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.5-dev" ;;
        64-11 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.4-dev" ;;
        32-11 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.4-dev" ;;
        64-10 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.4-dev" ;;
        32-10 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.4-dev" ;;
        * ) DEPS="$DEPS openssl-dev mariadb-10.1-dev" ;;
esac

. $MEDIR/phase-default-deps.sh

#sudo sh -c 'cd /usr/local/include; cp -a ncursesw ncurses'
#sudo sh -c 'cd /usr/local/lib; ln -sf libncursesw.so.6.1 libncurses.so; ln -sf libncurses++w.so.6.1 libncurses++.so; ldconfig'

. $MEDIR/phase-default-cc-opts.sh

echo $PATH | grep -q mysql || export PATH=$PATH:/usr/local/mysql/bin

#patch -p0 -i /mnt/sda1/lamp/patches/net-snmp-5.8-mariadb-10-3.patch

# patch for mariadb 10.5
patch apps/snmptrapd_sql.c <<'EOF'
        64-13 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.6-dev" ;;
        32-13 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.6-dev" ;;
        64-12 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.5-dev" ;;
        32-12 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.5-dev" ;;
        64-11 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.4-dev" ;;
        32-11 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.4-dev" ;;
        64-10 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.4-dev" ;;
        32-10 ) DEPS="$DEPS openssl-1.1.1-dev mariadb-10.4-dev" ;;
        * ) DEPS="$DEPS openssl-dev mariadb-10.1-dev" ;;
esac

. $MEDIR/phase-default-deps.sh

#sudo sh -c 'cd /usr/local/include; cp -a ncursesw ncurses'
#sudo sh -c 'cd /usr/local/lib; ln -sf libncursesw.so.6.1 libncurses.so; ln -sf libncurses++w.so.6.1 libncurses++.so; ldconfig'

. $MEDIR/phase-default-cc-opts.sh

echo $PATH | grep -q mysql || export PATH=$PATH:/usr/local/mysql/bin

#patch -p0 -i /mnt/sda1/lamp/patches/net-snmp-5.8-mariadb-10-3.patch

# patch for mariadb 10.5
patch apps/snmptrapd_sql.c <<'EOF'
--- snmptrapd_sql.c-orig
+++ snmptrapd_sql.c
@@ -456,6 +456,8 @@
     /** load .my.cnf values */
 #if HAVE_MY_LOAD_DEFAULTS
     my_load_defaults ("my", _sql.groups, &not_argc, &not_argv, 0);
+#elif defined(HAVE_MARIADB_LOAD_DEFAULTS)
+    mariadb_load_defaults ("my", _sql.groups, &not_argc, &not_argv);
 #elif defined(HAVE_LOAD_DEFAULTS)
     load_defaults ("my", _sql.groups, &not_argc, &not_argv);
 #else
EOF

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

# mariadb 10.3 breaks everything
#sed -i -e 's#/tmp/tcloop/mariadb-10.3-dev##g' apps/Makefile
#sed -i -e '/^MYSQL_INCLUDES/s#$# -I/usr/local/mysql/include/mysql/server#' apps/Makefile
#sed -i -e 's/my_init()/mysql_init(NULL)/' apps/snmptrapd_sql.c

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

