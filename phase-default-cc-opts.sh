if [ "$KBITS" == 32 ] ; then
	export CC="gcc -flto -fuse-linker-plugin -march=i486 -mtune=i686 -Os -pipe"
	export CXX="g++ -flto -fuse-linker-plugin -march=i486 -mtune=i686 -Os -pipe -fno-exceptions -fno-rtti"
else
	export CC="gcc -flto -fuse-linker-plugin -mtune=generic -Os -pipe"
	export CXX="g++ -flto -fuse-linker-plugin -mtune=generic -Os -pipe -fno-exceptions -fno-rtti"
fi

