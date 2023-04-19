OL=s
if [ "$KBITS" == 32 ] ; then
	export CC="gcc -march=i486 -mtune=i686 -O$OL -pipe"
	export CXX="g++ -march=i486 -mtune=i686 -O$OL -pipe"
else
	export CC="gcc -mtune=generic -O$OL -pipe"
	export CXX="g++ -mtune=generic -O$OL -pipe"
fi

