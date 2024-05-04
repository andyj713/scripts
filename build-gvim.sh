#!/bin/sh
#
# unzip vim-master and rename directory to gvim-master
# unzip vim-master again so there will be two directories
# because we need two builds, one with X (gvim) and one without (vim)
# run this script from the common parent of the two
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

EXT=gvim
VIMVERDIR=usr/local/share/vim/vim91

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

SHDIR=$(pwd)

DEPS="gettext glibc_gconv fontconfig-dev libXft-dev xorg-server-dev Xorg-7.7-dev gtk3-dev"

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

cd $SHDIR/vim$1
rm src/auto/config.cache
./configure \
	--prefix=/usr/local \
	--sysconfdir=/usr/local/etc \
	--localstatedir=/var \
	--mandir=/usr/local/share/man \
	--enable-multibyte \
	--with-tlib=ncursesw \
	--disable-canberra \
	--disable-libsodium \
	--disable-acl \
	--disable-gpm \
	--enable-gui=no \
	--without-x \
	|| exit

. $MEDIR/phase-default-make.sh

make install DESTDIR=$TCZ-vim || exit

cd $SHDIR/gvim$1
rm src/auto/config.cache
./configure \
	--prefix=/usr/local \
	--sysconfdir=/usr/local/etc \
	--localstatedir=/var \
	--mandir=/usr/local/share/man \
	--enable-multibyte \
	--with-tlib=ncursesw \
	--disable-canberra \
	--disable-libsodium \
	--disable-acl \
	--disable-gpm \
	--enable-gui=gtk3 \
	--with-x \
	|| exit

. $MEDIR/phase-default-make.sh

make install DESTDIR=$TCZ-gvim || exit

mkdir -p $TCZ-base/usr/local/
mv $TCZ-vim/usr/local/share $TCZ-base/usr/local

for a in $(diff -r $TCZ-gvim/usr/local/share $TCZ-base/usr/local/share \
		| grep "^Only in $TCZ-gvim" | sed -e 's#Only in ##' -e 's#: #/#')
	do b=$(echo $a | sed 's#TCZ-gvim#TCZ-base#')
	mkdir -p $(dirname $b)
	mv -f $a $b
done

rm -rf $TCZ-gvim/usr/local/share

mkdir -p $TCZ-doc/$VIMVERDIR
mv $TCZ-base/$VIMVERDIR/doc $TCZ-doc/$VIMVERDIR
mv $TCZ-base/usr/local/share/man $TCZ-doc/usr/local/share

mkdir -p $TCZ-tutor/$VIMVERDIR
mv $TCZ-base/$VIMVERDIR/tutor $TCZ-tutor/$VIMVERDIR
for a in $(find $TCZ-doc/usr/local -type f -name '*tutor*')
	do b=$(echo $a | sed 's#TCZ-doc#TCZ-tutor#')
	mkdir -p $(dirname $b)
	mv -f $a $b
done
for a in $(find $TCZ-vim/usr/local -type f -name '*tutor*')
	do b=$(echo $a | sed 's#TCZ-vim#TCZ-tutor#')
	mkdir -p $(dirname $b)
	mv -f $a $b
done
for a in $(find $TCZ-gvim/usr/local -type f -name '*tutor*')
	do b=$(echo $a | sed 's#TCZ-gvim#TCZ-tutor#')
	mkdir -p $(dirname $b)
	mv -f $a $b
done

. $MEDIR/phase-default-strip.sh
. $MEDIR/phase-default-set-perms.sh

mksquashfs $TCZ-vim $TCZTMP/$EXT/vim.tcz -noappend
mksquashfs $TCZ-gvim $TCZTMP/$EXT/gvim.tcz -noappend
mksquashfs $TCZ-base $TCZTMP/$EXT/gvim-base.tcz -noappend
mksquashfs $TCZ-doc $TCZTMP/$EXT/gvim-doc.tcz -noappend
mksquashfs $TCZ-tutor $TCZTMP/$EXT/gvim-tutor.tcz -noappend

