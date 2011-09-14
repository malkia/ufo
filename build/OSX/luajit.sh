LUAJIT=../../../luajit
rm *.tmp 1>/dev/null 2>/dev/null
make -C $LUAJIT -j BUILDMODE=dynamic CC="gcc -mmacosx-version-min=10.4 -arch i386"   LUAJIT_SO=libluajit.dylib TARGET_DYLIBPATH=libluajit.dylib cleaner
make -C $LUAJIT -j BUILDMODE=dynamic CC="gcc -mmacosx-version-min=10.4 -arch i386"   LUAJIT_SO=libluajit.dylib TARGET_DYLIBPATH=libluajit.dylib amalg
mv $LUAJIT/src/luajit luajit32.tmp
mv $LUAJIT/src/libluajit.dylib libluajit32.dylib.tmp
make -C $LUAJIT -j BUILDMODE=dynamic CC="gcc -mmacosx-version-min=10.4 -arch x86_64" LUAJIT_SO=libluajit.dylib TARGET_DYLIBPATH=libluajit.dylib cleaner
make -C $LUAJIT -j BUILDMODE=dynamic CC="gcc -mmacosx-version-min=10.4 -arch x86_64" LUAJIT_SO=libluajit.dylib TARGET_DYLIBPATH=libluajit.dylib amalg
mv $LUAJIT/src/luajit luajit64.tmp
mv $LUAJIT/src/libluajit.dylib libluajit64.dylib.tmp
lipo -create ./luajit*.tmp -output luajit
lipo -create ./libluajit*.dylib.tmp -output libluajit.dylib
# rm *.tmp 1>/dev/null 2>/dev/null
install_name_tool -id @rpath/libluajit.dylib libluajit.dylib
install_name_tool -change libluajit.dylib @executable_path/libluajit.dylib luajit
git --git-dir=$LUAJIT/.git log -1 >> luajit
git --git-dir=$LUAJIT/.git log -1 >> libluajit.dylib
mv luajit ../../bin/OSX
mv libluajit.dylib ../../bin/OSX
