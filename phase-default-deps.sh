DEPS="compiletc bash file squashfs-tools $DEPS"

case $TCVER in
        64-15 ) DEPS="$DEPS python3.9-dev lzip" ;;
        32-15 ) DEPS="$DEPS python3.9-dev" ;;
        64-14 ) DEPS="$DEPS python3.9-dev lzip" ;;
        32-14 ) DEPS="$DEPS python3.9-dev" ;;
        64-13 ) DEPS="$DEPS python3.6-dev lzip" ;;
        32-13 ) DEPS="$DEPS python3.6-dev" ;;
        64-12 ) DEPS="$DEPS python3.6-dev lzip" ;;
        32-12 ) DEPS="$DEPS python3.6-dev" ;;
        64-11 ) DEPS="$DEPS python3.6-dev lzip" ;;
        32-11 ) DEPS="$DEPS python3.6-dev" ;;
        64-10 ) DEPS="$DEPS python3.6-dev lzip" ;;
        32-10 ) DEPS="$DEPS python3.6-dev" ;;
        * ) DEPS="$DEPS" ;;
esac

NOTFOUND=""
for a in $DEPS; do
##	ls -ld /usr/local/tce.installed
	tce-load -i $a || tce-load -iwl $a || NOTFOUND=x
done
test -z "$NOTFOUND" || exit

#sudo find /usr/lib -name '*.la' -exec rm -f {} \;
#sudo find /usr/local/lib -name '*.la' -exec rm -f {} \;

#sudo rm /usr/lib/*.la /usr/local/lib/*.la
