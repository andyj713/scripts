for x in $(find $TCZTMP/$EXT -maxdepth 1 -name 'TCZ' -type d); do
	sudo chown -R root.root $x
	sudo chown -R root.staff $x/usr/local/tce.installed
	sudo chmod -R 775 $x/usr/local/tce.installed
done
for x in $(find $TCZTMP/$EXT -maxdepth 1 -name 'TCZ-*' -type d); do
	sudo chown -R root.root $x
	sudo chown -R root.staff $x/usr/local/tce.installed
	sudo chmod -R 775 $x/usr/local/tce.installed
done
