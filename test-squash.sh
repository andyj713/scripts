tce-load -i squashfs-tools
mkdir gzip lzo xz zstd
for a in gzip lzo xz zstd; do for b in /mnt/sda1/lamp64/tmp/*; do for c in $b/TCZ*; do mksquashfs $c $a/$(basename $b)-$(basename $c).tcz -comp $a ; done; done; done
mkdir test
time sh -c 'for a in $(seq 1 10); do for b in gzip/*; do sudo unsquashfs -f -d test $b; done; done'
time sh -c 'for a in $(seq 1 10); do for b in lzo/*; do sudo unsquashfs -f -d test $b; done; done'
time sh -c 'for a in $(seq 1 10); do for b in xz/*; do sudo unsquashfs -f -d test $b; done; done'
time sh -c 'for a in $(seq 1 10); do for b in zstd/*; do sudo unsquashfs -f -d test $b; done; done'
du -ms *
cd /mnt/sda1/lamp64/tmp/
find */TCZ* -maxdepth 0
