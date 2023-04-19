#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

FULLVER=${PWD##*-}
PGMAJ=${FULLVER%%.*}
MINPVER=${FULLVER#*.}
PGMIN=${MINPVER%%.*}

if [ $PGMAJ -eq 9 ] ; then
	EXT=postgresql-9.$PGMIN
	PGDIR=pgsql9$PGMIN
else
	EXT=postgresql-$PGMAJ
	PGDIR=pgsql$PGMAJ
fi

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="libxml2-dev libxslt-dev gettext perl5 tzdata tcl8.6-dev"

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

for a in $(grep -l -r 'define NAMEDATALEN' *); do
	sed -i -e 's/define NAMEDATALEN .*$/define NAMEDATALEN 128/' $a
done

./configure \
	--prefix=/usr/local/$PGDIR \
	--localstatedir=/var \
	--disable-rpath \
	--with-openssl \
	--with-uuid=e2fs \
	--with-libxml \
	--with-libxslt \
	--with-perl \
	--with-python \
	--with-tcl \
	--enable-nls \
	--with-system-tzdata=/usr/local/share/zoneinfo \
	|| exit

. $MEDIR/phase-default-make.sh
. $MEDIR/phase-default-make-install.sh

cd contrib && make && make install DESTDIR=$TCZ && cd .. || exit

mkdir -p $TCZ-dev/usr/local/$PGDIR/bin
mkdir -p $TCZ-dev/usr/local/$PGDIR/lib
mkdir -p $TCZ-client/usr/local/$PGDIR/bin
mkdir -p $TCZ-client/usr/local/$PGDIR/lib

mv $TCZ/usr/local/$PGDIR/include $TCZ-dev/usr/local/$PGDIR
mv $TCZ/usr/local/$PGDIR/lib/pgxs $TCZ-dev/usr/local/$PGDIR/lib
mv $TCZ/usr/local/$PGDIR/lib/pkgconfig $TCZ-dev/usr/local/$PGDIR/lib
mv $TCZ/usr/local/$PGDIR/lib/*.a $TCZ-dev/usr/local/$PGDIR/lib
cp -a $TCZ/usr/local/$PGDIR/lib $TCZ-dev/usr/local/$PGDIR
mv $TCZ/usr/local/$PGDIR/bin/pg_config $TCZ-dev/usr/local/$PGDIR/bin

cp $TCZ/usr/local/$PGDIR/bin/psql $TCZ-client/usr/local/$PGDIR/bin
cp -a $TCZ/usr/local/$PGDIR/lib/libpq.so* $TCZ-client/usr/local/$PGDIR/lib

for x in '' '-dev' '-client'; do
mkdir -p $TCZ$x/usr/local/tce.installed
cat << EOF > $TCZ$x/usr/local/tce.installed/$EXT$x
#!/bin/sh
[ \$(grep $PGDIR /etc/ld.so.conf) ] || echo /usr/local/$PGDIR/lib >> /etc/ld.so.conf
ldconfig -q
EOF
done

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

