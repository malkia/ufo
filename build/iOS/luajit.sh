LUAJIT=../../../luajit
DEVDIR=/Developer/Platforms
IOSVER=iPhoneOS5.0.sdk
SIMVER=iPhoneSimulator5.0.sdk
IOSDIR=$DEVDIR/iPhoneOS.platform/Developer
SIMDIR=$DEVDIR/iPhoneSimulator.platform/Developer
IOSBIN=$IOSDIR/usr/bin/
SIMBIN=$SIMDIR/usr/bin/
rm *.tmp 1>/dev/null 2>/dev/null
make -j -C $LUAJIT BUILDMODE=mixed HOST_CFLAGS="-arch i386" HOST_LDFLAGS="-arch i386" TARGET_SYS=iOS LUAJIT_SO=libluajit.dylib TARGET=arm cleaner
make -j -C $LUAJIT BUILDMODE=mixed HOST_CFLAGS="-arch i386" HOST_LDFLAGS="-arch i386" TARGET_SYS=iOS LUAJIT_SO=libluajit.dylib TARGET=arm amalg CROSS=$IOSBIN TARGET_FLAGS="-isysroot $IOSDIR/SDKs/$IOSVER -arch armv7"
mv $LUAJIT/src/luajit luajitA7.tmp
mv $LUAJIT/src/libluajit.dylib libluajitA7.dylib.tmp
make -j -C $LUAJIT BUILDMODE=mixed HOST_CFLAGS="-arch i386" HOST_LDFLAGS="-arch i386" TARGET_SYS=iOS LUAJIT_SO=libluajit.dylib TARGET=arm cleaner
make -j -C $LUAJIT BUILDMODE=mixed HOST_CFLAGS="-arch i386" HOST_LDFLAGS="-arch i386" TARGET_SYS=iOS LUAJIT_SO=libluajit.dylib TARGET=arm amalg CROSS=$IOSBIN TARGET_FLAGS="-isysroot $IOSDIR/SDKs/$IOSVER -arch armv6"
mv $LUAJIT/src/luajit luajitA6.tmp
mv $LUAJIT/src/libluajit.dylib libluajitA6.dylib.tmp
make -j -C $LUAJIT BUILDMODE=mixed HOST_CFLAGS="-arch i386" HOST_LDFLAGS="-arch i386" TARGET_SYS=iOS LUAJIT_SO=libluajit.dylib TARGET=x86 CC=gcc-4.2 cleaner
make -j -C $LUAJIT BUILDMODE=mixed HOST_CFLAGS="-arch i386" HOST_LDFLAGS="-arch i386" TARGET_SYS=iOS LUAJIT_SO=libluajit.dylib TARGET=x86 CC=gcc-4.2 amalg CROSS=$SIMBIN TARGET_FLAGS="-isysroot $SIMDIR/SDKs/$SIMVER -arch i386"
mv $LUAJIT/src/luajit luajit32.tmp
mv $LUAJIT/src/libluajit.dylib libluajit32.dylib.tmp
lipo -create ./luajit*.tmp -output luajit
lipo -create ./libluajit*.dylib.tmp -output libluajit.dylib
rm *.tmp 1>/dev/null 2>/dev/null
install_name_tool -id @rpath/libluajit.dylib libluajit.dylib
install_name_tool -change libluajit.dylib @executable_path/libluajit.dylib luajit
git --git-dir=$LUAJIT/.git log -1 >> luajit
git --git-dir=$LUAJIT/.git log -1 >> libluajit.dylib
mv luajit ../../bin/iOS
mv libluajit.dylib ../../bin/iOS
