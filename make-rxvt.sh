#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

. $MEDIR/phase-default-vars.sh

SCRIPTS=$BASE/scripts
STAGE=$BASE$KBITS/stage
TCEOPT=/mnt/sda1/tce$KBITS/optional

PROD="$SCRIPTS"

copy_tcz(){
        for a in $TCZTMP/$1/*.tcz; do
                cp $a $STAGE
                cp $a $TCEOPT
                md5sum $a > $TCEOPT/$(basename $a).md5.txt
        done
}

#
#
#
build_one(){
	EXT="$1"
	PKG=""
	PKGVER=""
	SRC=""
	STYPE=""
	SVER=""
	test -z "$2" && PKG="$1" || { PKG="$2" ; PKGVER="$3" ; }
	SRC=$(basename $(find $SOURCE -regex ".*/$EXT[\.-].*" | sort | head -1))
	STYPE=${SRC##*.}
	SVER=${SRC#$EXT*}

	echo "PKG=$PKG"
	echo "SRC=$SRC"
	echo "STYPE=$STYPE"
	cd $BUILD
	case $STYPE in
		zip)
			SVER=${SVER%.zip}
			echo "SVER=$SVER"
			sudo rm -rf $BUILD/$EXT$SVER
			unzip -q -o $SOURCE/$SRC
			;;
		tgz)
			SVER=${SVER%.tgz}
			echo "SVER=$SVER"
			sudo rm -rf $BUILD/$EXT$SVER
			tar xf $SOURCE/$SRC
			;;
		gz|bz2|xz)
			SVER=${SVER%.tar*}
			echo "SVER=$SVER"
			sudo rm -rf $BUILD/$EXT$SVER
			tar xf $SOURCE/$SRC
			;;
	esac
	cd $BUILD/$EXT$SVER
	echo -e "\n=====  build-$PKG.sh =====\n"
	$PROD/build-$PKG.sh
	copy_tcz $PKG$PKGVER
}

sudo cp $BASE$KBITS/la-files/* /usr/local/lib

touch $STAGE/begin-time

cd $BUILD
sudo rm -rf $BUILD/rxvt-unicode-9.22
tar xf $SOURCE/rxvt-unicode-9.22.tar.bz2
cd $BUILD/rxvt-unicode-9.22
cp -r $SOURCE/urxvt-patches .
echo -e "\n=====  build-rxvt.sh =====\n"
$PROD/build-rxvt.sh
copy_tcz rxvt

