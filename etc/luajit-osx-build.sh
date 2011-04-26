LUAJIT_SRC=../../luajit
echo Looking for LuaJIT in here LUAJIT_SRC=$LUAJIT_SRC

make -C $LUAJIT_SRC clean
make -C $LUAJIT_SRC "CC=gcc -m32" amalg
mv $LUAJIT_SRC/src/luajit       luajit32.tmp
mv $LUAJIT_SRC/src/libluajit.so luajit32.dylib.tmp

make -C $LUAJIT_SRC clean
make -C $LUAJIT_SRC "CC=gcc -m64" amalg
mv $LUAJIT_SRC/src/luajit       luajit64.tmp
mv $LUAJIT_SRC/src/libluajit.so luajit64.dylib.tmp

lipo -create -arch i386 luajit32.tmp       -arch x86_64 luajit64.tmp       -output     ../luajit
lipo -create -arch i386 luajit32.dylib.tmp -arch x86_64 luajit64.dylib.tmp -output ../bin/luajit.dylib

rm luajit*.tmp

