#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

. $MEDIR/phase-default-vars.sh

export TZ=UTC

build_dir(){
	EXT="$1"                                         
	SRC=$BUILD/$(basename $(find $BUILD -regex ".*/$EXT[\.-].*" | sort | head -1))
}


for PKG in jemalloc libevent libfastjson libgd lighttpd liblognorm tcllib apr-util; do
	build_dir $PKG
	cd $SRC
	echo $(pwd)
	make check 2>&1 | tee make-check-$PKG.log
done


for PGVER in 9.5 9.6 10 11 12 13 14 15; do
	PKG=postgresql-$PGVER
	build_dir $PKG
	cd $SRC
	echo $(pwd)
	make check 2>&1 | tee make-check-$PKG.log
done

	
for PKG in net-snmp tcltls; do
	build_dir $PKG
	cd $SRC
	echo $(pwd)
	make test 2>&1 | tee make-test-$PKG.log
done
	

build_dir tcl8.6
cd $SRC/unix
echo $(pwd)
export TZ=UTC
make test 2>&1 | tee make-check-tcl.log


build_dir libaio
cd $SRC
echo $(pwd)
sudo make check 2>&1 | tee make-check-libaio.log

exit

build_dir bind
cd $SRC
echo $(pwd)
sudo $SRC/bin/tests/system/ifconfig.sh up
make check 2>&1 | tee make-check-bind.log


build_dir openldap
cd $SRC
echo $(pwd)
export NOEXIT=1
make check 2>&1 | tee make-check-openldap.log


build_dir php
cd $BASE/php-tests                                                      
for a in $(find . -type f); do /bin/cp -f $a $SRC/$a; done
cd $SRC

tce-load -i msodbcsql

sudo /usr/local/sbin/snmpd -c /mnt/sda1/lamp/php-tests/ext/snmp/tests/snmpd.conf -Lf /var/log/snmpd.log &
sudo /usr/local/libexec/slapd -4 -f /usr/local/etc/openldap/slapd.conf &
PGVER=15 LD_LIBRARY_PATH=/usr/local/pgsql$PGVER/lib /usr/local/pgsql$PGVER/bin/pg_ctl -D /mnt/sdb1/lamp/pgsql-DB/TEST -l /mnt/sdb1/lamp/pgsql-DB/TEST.log start &
sudo /usr/local/mysql/bin/mysqld_safe --basedir=/usr/local/mysql --datadir=/mnt/sdb1/lamp/maria-DB/data --syslog --user=tc &

TEST_PHP_ARGS="-q" make test 2>&1 | tee make-test-php.log

sudo /usr/local/mysql/bin/mysqladmin shutdown
PGVER=15 LD_LIBRARY_PATH=/usr/local/pgsql$PGVER/lib /usr/local/pgsql$PGVER/bin/pg_ctl -D /mnt/sdb1/lamp/pgsql-DB/TEST stop
sudo kill -INT $(pidof slapd)
sudo kill -INT $(pidof snmpd)


