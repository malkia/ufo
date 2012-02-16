set -e
LUAJIT=../../../luajit
FLAGS='-mmacosx-version-min=10.5 -DLUAJIT_ENABLE_LUA52COMPAT'
(rm *.tmp 1>/dev/null 2>/dev/null) && true
make -C $LUAJIT -j BUILDMODE=dynamic CC="gcc $FLAGS -arch i386"   LUAJIT_SO=luajit.dylib TARGET_DYLIBPATH=luajit.dylib cleaner
make -C $LUAJIT -j BUILDMODE=dynamic CC="gcc $FLAGS -arch i386"   LUAJIT_SO=luajit.dylib TARGET_DYLIBPATH=luajit.dylib amalg
mv $LUAJIT/src/luajit luajit32.exe.tmp
mv $LUAJIT/src/luajit.dylib luajit32.dylib.tmp
make -C $LUAJIT -j BUILDMODE=dynamic CC="gcc $FLAGS -arch x86_64" LUAJIT_SO=luajit.dylib TARGET_DYLIBPATH=luajit.dylib cleaner
make -C $LUAJIT -j BUILDMODE=dynamic CC="gcc $FLAGS -arch x86_64" LUAJIT_SO=luajit.dylib TARGET_DYLIBPATH=luajit.dylib amalg
mv $LUAJIT/src/luajit luajit64.exe.tmp
mv $LUAJIT/src/luajit.dylib luajit64.dylib.tmp
lipo -create ./luajit*.exe.tmp -output luajit
lipo -create ./luajit*.dylib.tmp -output luajit.dylib
# rm *.tmp 1>/dev/null 2>/dev/null
install_name_tool -id @loader_path/luajit.dylib luajit.dylib
install_name_tool -change luajit.dylib @executable_path/luajit.dylib luajit
git --git-dir=$LUAJIT/.git log -1 >> luajit
git --git-dir=$LUAJIT/.git log -1 >> luajit.dylib
mv luajit ../../bin/OSX
mv luajit.dylib ../../bin/OSX/luajit.dylib
rm *.tmp
echo Done

