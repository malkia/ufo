LUAJIT=../../luajit
#echo LUAJIT=$LUAJIT

#pushd $LUAJIT/src

ISDK=/Developer/Platforms/iPhoneSimulator.platform/Developer
ISDKVER=iPhoneSimulator5.0.sdk
ISDKP=$ISDK/usr/bin/

echo TEST1 ${0##*/} 1TSET
echo TEST1 ${0%/*} 1TSET

: <<EOF

make -j CC="gcc-4.2 -arch i386" CROSS=$ISDKP TARGET_FLAGS="-isysroot $ISDK/SDKs/$ISDKVER" TARGET=X86 TARGET_SYS=iOS cleaner amalg
mv luajit       luajit32.x.tmp
mv libluajit.a  luajit32.a.tmp
mv libluajit.so luajit32.l.tmp



ISDK=/Developer/Platforms/iPhoneOS.platform/Developer
ISDKVER=iPhoneOS5.0.sdk
ISDKP=$ISDK/usr/bin/

make -n CC="gcc-4.2" HOST_CFLAGS="-arch i386" HOST_LDFLAGS="-arch i386" CROSS=$ISDKP TARGET_FLAGS="-arch armv7 -isysroot $ISDK/SDKs/$ISDKVER" TARGET=arm TARGET_SYS=iOS amalg
#mv luajit       luajit7.x.tmp
#mv libluajit.a  luajit7.a.tmp
#mv libluajit.so luajit7.l.tmp


make "CC=gcc-4.2 -m32 -mmacosx-version-min=10.6" cleaner amalg
mv luajit       luajit32.x.tmp
mv libluajit.a  luajit32.a.tmp
mv libluajit.so luajit32.l.tmp

make "CC=gcc-4.2 -m64 -mmacosx-version-min=10.6" cleaner amalg
mv luajit       luajit64.x.tmp
mv libluajit.a  luajit64.a.tmp
mv libluajit.so luajit64.l.tmp

# Thanks to Adam Strzelecki for the iOS compilation

make CC="gcc-4.2" HOST_CFLAGS="-m32 -arch i386" HOST_LDFLAGS="-m32 -arch i386" CROSS=$ISDKP TARGET_FLAGS="-arch armv6 -isysroot $ISDK/SDKs/$ISDKVER" TARGET=arm TARGET_SYS=iOS cleaner amalg
mv luajit       luajit6.x.tmp
mv libluajit.a  luajit6.a.tmp
mv libluajit.so luajit6.l.tmp


rm luajit luajit.a luajit.dylib

lipo -create luajit*.x.tmp -output luajit
lipo -create luajit*.a.tmp -output luajit.a
lipo -create luajit*.l.tmp -output luajit.dylib

file luajit
file luajit.a
file luajit.dylib

rm luajit*.tmp

git log -1 >> luajit
git log -1 >> luajit.dylib

popd

mv $LUAJIT/src/luajit       ../bin/OSX
mv $LUAJIT/src/luajit.dylib ../bin/OSX
mv $LUAJIT/src/luajit.a     ../lib/OSX

EOF

