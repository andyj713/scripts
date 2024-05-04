#!/bin/sh
#
EXT=mariadb-11.2
TCZROOT=/mnt/sdb1/lamp/test/tmp/$EXT

PATH_MYSQL=usr/local/mysql                                                                                       
PATH_MYDATA=opt/mysql                                                                                            
PATH_MYCONF=usr/local/etc/mysql                                                                                  
PATH_MYSOCK=var/run

sudo rm -rf $TCZROOT/*

TCZ=$TCZROOT/TCZ

DEPS="compiletc perl5 cmake ncursesw-dev readline-dev openssl-dev
	liblzma-dev bzip2-dev pcre21042-dev libaio-dev liblz4-dev
	zstd-dev curl-dev lzo-dev jemalloc-dev libxml2-dev
	libevent-dev openldap-dev unixODBC-dev tcp_wrappers-dev
	libjudy-dev boost-1.84-dev libsnappy-dev squashfs-tools bash"

#DEPS="$DEPS cracklib-dev libmsgpack-dev"

# 32 bit
#DEPS="$DEPS Linux-PAM-dev"
# 64 bit
DEPS="$DEPS linux-pam-dev"

NOTFOUND=""
for a in $DEPS
         do tce-load -i $a || tce-load -iwl $a || NOTFOUND=x
done
test -z "$NOTFOUND" || exit

# fix to compile
sed -i '/add_subdirectory(data)/d' storage/mroonga/vendor/groonga/CMakeLists.txt

# 64-bit
export CC="gcc -flto -fuse-linker-plugin -mtune=generic -Os -pipe -fno-strict-aliasing -I/usr/local/include/ncursesw"
export CXX="g++ -flto -fuse-linker-plugin -mtune=generic -Os -pipe -fno-strict-aliasing -I/usr/local/include/ncursesw -fpermissive"

# 32-bit
#export CC="gcc -flto -fuse-linker-plugin -march=i686 -Os -pipe -fno-strict-aliasing"
#export CXX="g++ -flto -fuse-linker-plugin -march=i686 -Os -pipe -fno-strict-aliasing"

mkdir build
cd build

cmake 	-LH \
	-DCMAKE_INSTALL_PREFIX=/$PATH_MYSQL \
	-DMYSQL_DATADIR=/$PATH_MYDATA \
	-DINSTALL_SYSCONFDIR=/$PATH_MYCONF \
	-DINSTALL_SYSCONF2DIR=/$PATH_MYCONF/conf.d \
	-DINSTALL_UNIX_ADDRDIR=/$PATH_MYSOCK/mysql.sock \
	-DINSTALL_LAYOUT=STANDALONE \
	-DINSTALL_INCLUDEDIR=include \
	-DCMAKE_BUILD_TYPE=MinSizeRel \
	-DFEATURE_SET=xsmall \
	-DWITH_SSL=system \
	-DCURSES_NCURSES_LIBRARY=/usr/local/lib/libncursesw.so \
	-DCURSES_INCLUDE_PATH=/usr/local/include/ncursesw \
	-DCURSES_FORM_LIBRARY=/usr/local/lib/libformw.so \
	-DCURSES_EXTRA_LIBRARY=/usr/local/lib/libncurses++w.so \
	-DMYSQL_MAINTAINER_MODE=OFF \
	-DWITH_EXTRA_CHARSETS=complex \
	-DWITH_UNIXODBC=ON \
	-DWITH_LIBWRAP=ON \
	-DSKIP_TESTS=ON \
	-DWITH_SYSTEMD=no \
	-DMRN_GROONGA_EMBED=OFF \
	-DWITHOUT_MROONGA_STORAGE_ENGINE=YES \
	-DTOKUDB_OK=0 \
	.. || exit 1

# set compiler optimization level
find . -name Makefile -type f -exec sed -i -e 's/-O2//g' {} \;
find . -name Makefile -type f -exec sed -i -e 's/ -g[1-9] / -g0 /g' {} \;
find . -name Makefile -type f -exec sed -i -e 's/ -g / -g0 /g' {} \;

cmake --build . || exit 1
cmake --build . --target test || exit 1
make install DESTDIR=$TCZ || exit 1

cd ..
for a in $(find $TCZ -type f); do file -b $a | grep -q '^ELF .*not stripped$' && strip $a; done

mkdir -p $TCZ-doc/$PATH_MYSQL
mkdir -p $TCZ-test/$PATH_MYSQL
mkdir -p $TCZ-dev/$PATH_MYSQL/bin
mkdir -p $TCZ-dev/$PATH_MYSQL/lib
mkdir -p $TCZ-dev/$PATH_MYSQL/share

mv $TCZ/usr/local/etc/mysql/init.d $TCZ/usr/local/etc
mv $TCZ/usr/local/etc/mysql/logrotate.d $TCZ/usr/local/etc
sed -i -e 's#/etc/my.cnf.d#/usr/local/etc/mysql/conf.d#' $TCZ/usr/local/etc/mysql/my.cnf

mv $TCZ/$PATH_MYSQL/docs $TCZ-doc/$PATH_MYSQL
mv $TCZ/$PATH_MYSQL/man $TCZ-doc/$PATH_MYSQL

mv $TCZ/$PATH_MYSQL/mariadb-test $TCZ-test/$PATH_MYSQL
mv $TCZ/$PATH_MYSQL/sql-bench $TCZ-test/$PATH_MYSQL

mv $TCZ/$PATH_MYSQL/include $TCZ-dev/$PATH_MYSQL
mv $TCZ/$PATH_MYSQL/bin/mysql_config $TCZ-dev/$PATH_MYSQL/bin
mv $TCZ/$PATH_MYSQL/lib/pkgconfig $TCZ-dev/$PATH_MYSQL/lib
#mv $TCZ/$PATH_MYSQL/share/pkgconfig $TCZ-dev/$PATH_MYSQL/share
mv $TCZ/$PATH_MYSQL/share/aclocal $TCZ-dev/$PATH_MYSQL/share

for a in $(find $TCZ -name '*.a'); do
        b=$(echo $(dirname $a) | sed "s#$TCZ#$TCZ-dev#")
        mkdir -p $b
        mv $a $b
done

mkdir -p $TCZ-client/$PATH_MYSQL/bin
mkdir -p $TCZ-client/$PATH_MYSQL/lib
mkdir -p $TCZ-client/$PATH_MYCONF/conf.d

# copy files for mariadb client; someone should check this list

for a in $(echo "lib/libmariadb.so
lib/libmysqlclient.so
lib/libmysqlclient_r.so
lib/libmariadb.so.3
bin/mariadb-show
bin/mysqlbinlog
bin/mysqldump
bin/mysql
bin/mariadb-slap
bin/mysqlshow
bin/mariadb-binlog
bin/mysqlimport
bin/mysqlslap
bin/mysql_upgrade
bin/mytop
bin/mariadb-dump
bin/mysqlcheck
bin/my_print_defaults
bin/mariadb
bin/mysqladmin
bin/mariadb-upgrade
bin/mariadb-check
bin/mariadb-admin
bin/mariadb-import"); do sudo /bin/cp -a $TCZ/$PATH_MYSQL/$a $TCZ-client/$PATH_MYSQL/$a; done

for a in $(echo "conf.d/mysql-clients.cnf
conf.d/enable_encryption.preset
conf.d/client.cnf
my.cnf"); do sudo /bin/cp -a $TCZ/$PATH_MYCONF/$a $TCZ-client/$PATH_MYCONF/$a; done

sudo chown -R root.root $TCZ*

mksquashfs $TCZ $TCZROOT/$EXT.tcz -noappend
mksquashfs $TCZ-dev $TCZROOT/$EXT-dev.tcz -noappend
mksquashfs $TCZ-doc $TCZROOT/$EXT-doc.tcz -noappend
mksquashfs $TCZ-test $TCZROOT/$EXT-test.tcz -noappend
mksquashfs $TCZ-client $TCZROOT/$EXT-client.tcz -noappend

