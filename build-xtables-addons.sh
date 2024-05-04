#!/bin/sh
#
ME=$(readlink -f "$0")
MEDIR=${ME%/*}

KVER=$(uname -r)
EXT=xtables-addons-$KVER

. $MEDIR/phase-default-vars.sh
. $MEDIR/phase-default-init.sh

DEPS="bash bc tcl8.6 glibc_apps iptables-dev"

case $TCVER in
	64-15 ) DEPS="$DEPS ipv6-netfilter-KERNEL" ;;
	32-15 ) DEPS="$DEPS ipv6-netfilter-KERNEL" ;;
	64-14 ) DEPS="$DEPS ipv6-netfilter-KERNEL" ;;
	32-14 ) DEPS="$DEPS ipv6-netfilter-KERNEL" ;;
	64-13 ) DEPS="$DEPS ipv6-netfilter-KERNEL" ;;
	32-13 ) DEPS="$DEPS ipv6-netfilter-KERNEL" ;;
	64-12 ) DEPS="$DEPS ipv6-netfilter-KERNEL" ;;
	32-12 ) DEPS="$DEPS ipv6-netfilter-KERNEL" ;;
	64-11 ) DEPS="$DEPS ipv6-netfilter-KERNEL" ;;
	32-11 ) DEPS="$DEPS ipv6-netfilter-KERNEL" ;;
	64-10 ) DEPS="$DEPS netfilter-KERNEL" ;;
	32-10 ) DEPS="$DEPS netfilter-KERNEL" ;;
	* ) DEPS="$DEPS netfilter-KERNEL" ;;
esac

. $MEDIR/phase-default-deps.sh
. $MEDIR/phase-default-cc-opts.sh

#sudo ln -sf $BASE$KBITS/kernel/linux-$KVER /lib/modules/$(uname -r)/build
#[ -e /etc/sysconfig/tcedir/copy2fs.flg ] && \
#        sudo ln -sf /usr /lib/modules/$(uname -r)/build || \
#        sudo ln -sf /tmp/tcloop/linux-4.19_api_headers/usr /lib/modules/$(uname -r)/build

./autogen.sh

for a in $(grep -r -l /usr/share/xt_geoip *); do sed -i -e 's#/usr/share/xt_geoip#/usr/local/share/xt_geoip/LE#g' $a; done

./configure \
	--prefix=/usr/local \
	--localstatedir=/var \
	--sysconfdir=/usr/local/etc \
	--with-kbuild=$LAMP/kernel/linux-${KVER%-*} \
	|| exit

bash -c make || exit

. $MEDIR/phase-default-make-install.sh

gzip $TCZ/lib/modules/$KVER/extra/*.ko
depmod -b $TCZ
strip --strip-unneeded $TCZ/usr/local/lib/xtables/*
strip --strip-unneeded $TCZ/usr/local/lib/*.so*
strip --strip-unneeded $TCZ/usr/local/sbin/iptaccount
cp $BASE/contrib/xt_geoip_build.tcl $TCZ/usr/local/libexec/xtables-addons

. $MEDIR/phase-default-set-perms.sh
. $MEDIR/phase-default-squash-tcz.sh

