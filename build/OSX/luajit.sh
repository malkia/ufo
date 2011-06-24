LUAJIT=../../../luajit
make -C $LUAJIT -j BUILDMODE=dynamic CC="gcc-4.2 -mmacosx-version-min=10.4 -arch i386"   cleaner amalg
mv $LUAJIT/src/luajit       ./luajit32.tmp
mv $LUAJIT/src/libluajit.so ./libluajit32.so.tmp
make -C $LUAJIT -j BUILDMODE=dynamic CC="gcc-4.2 -mmacosx-version-min=10.4 -arch x86_64" cleaner amalg
mv $LUAJIT/src/luajit       ./luajit64.tmp
mv $LUAJIT/src/libluajit.so ./libluajit64.so.tmp
lipo -create ./luajit32.tmp        ./luajit64.tmp      -output ../../bin/OSX/luajit
lipo -create ./libluajit32.so.tmp ./libluajit64.so.tmp -output ../../bin/OSX/libluajit.so
rm *.tmp

