#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-make-funcs.sh

touch $STAGE/begin-time

cd $BUILD

SRC=$(basename $(find $SOURCE -regex ".*/vim[\.-].*" | sort | head -1))
STYPE=${SRC##*.}
SVER=${SRC#vim*}
SVER=${SVER%.tar*}
echo SRC="$SRC"
echo STYPE="$STYPE"
echo SVER="$SVER"
sudo rm -rf vim$SVER gvim$SVER
tar xf $SOURCE/$SRC
mv vim$SVER gvim$SVER
tar xf $SOURCE/$SRC
echo -e "\n=====  build-gvim.sh =====\n"
$PROD/build-gvim.sh $SVER
copy_tcz gvim

