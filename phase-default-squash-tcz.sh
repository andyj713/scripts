
for x in $(find $TCZTMP/$EXT -maxdepth 1 -name 'TCZ' -type d); do
	sudo mksquashfs $x $TCZTMP/$EXT/$EXT.tcz -noappend
done
for x in $(find $TCZTMP/$EXT -maxdepth 1 -name 'TCZ-*' -type d); do
	sudo mksquashfs $x $TCZTMP/$EXT/$EXT-${x##*-}.tcz -noappend
done
