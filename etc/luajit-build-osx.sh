export LUAJIT=../../luajit
echo LUAJIT=$LUAJIT

pushd $LUAJIT/src

make "CC=gcc -m32 -mmacosx-version-min=10.4" clean amalg
mv luajit       luajit32.x.tmp
mv libluajit.a  luajit32.a.tmp
mv libluajit.so luajit32.l.tmp

make "CC=gcc -m64 -mmacosx-version-min=10.4" clean amalg
mv luajit       luajit64.x.tmp
mv libluajit.a  luajit64.a.tmp
mv libluajit.so luajit64.l.tmp

ISDK=/Developer/Platforms/iPhoneOS.platform/Developer
ISDKVER=iPhoneOS4.3.sdk
ISDKP=$ISDK/usr/bin/

# Thanks to Adam Strzelecki for the iOS compilation

make HOST_CC="gcc -m32 -arch i386" CROSS=$ISDKP TARGET_FLAGS="-arch armv6 -isysroot $ISDK/SDKs/$ISDKVER" TARGET=arm TARGET_SYS=iOS clean amalg
mv luajit       luajit6.x.tmp
mv libluajit.a  luajit6.a.tmp
mv libluajit.so luajit6.l.tmp

make HOST_CC="gcc -m32 -arch i386" CROSS=$ISDKP TARGET_FLAGS="-arch armv7 -isysroot $ISDK/SDKs/$ISDKVER" TARGET=arm TARGET_SYS=iOS clean amalg
mv luajit       luajit7.x.tmp
mv libluajit.a  luajit7.a.tmp
mv libluajit.so luajit7.l.tmp 

rm luajit luajit.a luajit.dylib 1>nul 2>nul

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

mv $LUAJIT/src/luajit       ..
mv $LUAJIT/src/luajit.dylib ../bin
mv $LUAJIT/src/luajit.a     ../lib/osx

