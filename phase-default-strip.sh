for a in $(find $TCZ* -type f); do file -b $a | grep -q '^ELF .*not stripped$' && strip --strip-unneeded $a; done

