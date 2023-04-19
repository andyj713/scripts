OL=s
if [ "$KBITS" == 32 ] ; then
	export CC="gcc -flto -fuse-linker-plugin -march=i486 -mtune=i686 -O$OL -pipe"
	export CXX="g++ -flto -fuse-linker-plugin -march=i486 -mtune=i686 -O$OL -pipe"
else
	export CC="gcc -flto -fuse-linker-plugin -mtune=generic -O$OL -pipe"
	export CXX="g++ -flto -fuse-linker-plugin -mtune=generic -O$OL -pipe"
fi

