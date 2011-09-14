set -e

#export PKG_CONFIG_PATH=/usr/lib/pkgconfig

PROJECT=cairo
SOURCE=../../../$PROJECT
OBJDIR=src/.libs
DYLIB=lib$PROJECT.2.dylib
TARGET=../../bin/OSX/lib$PROJECT.dylib

export UFO_LIBDIR="-L../../ufo/bin/OSX"
export png_CFLAGS=-I../../libpng

CONFIGURATION="\
    --enable-static=no \
    --enable-xlib=no \
    --enable-xlib-xrender=no \
    --enable-xcb=no \
    --enable-xlib-xcb=no \
    --enable-xcb-shm=no \
    --enable-test-surfaces=no \
    --enable-full-testing=no \
\
    --enable-fc=no \
    --enable-ft=no \
\
    --enable-quartz-image=yes \
\
    --enable-xml=yes \
    --enable-quartz=yes \
    --enable-tee=yes \
    --enable-script=yes \
    --enable-png=yes \
"

pushd $SOURCE
git clean -fdx
NOCONFIGURE=1 ./autogen.sh
./configure CPP="cpp" CC="cc -mmacosx-version-min=10.5 -arch i386 -D__LP64__=1" $CONFIGURATION
echo .PHONY: all > perf/Makefile
echo .PHONY: all > perf/micro/Makefile
echo .PHONY: all > test/Makefile
echo .PHONY: all > test/pdiff/Makefile
echo .PHONY: all > doc/Makefile
echo .PHONY: all > doc/public/Makefile
make -j
popd
mv $SOURCE/$OBJDIR/$DYLIB $TARGET.32.tmp
install_name_tool -id @rpath/lib$PROJECT.dylib $TARGET.32.tmp
install_name_tool -change /opt/local/lib/libpixman-1.0.dylib @rpath/libpixman.dylib $TARGET.32.tmp
#install_name_tool -change /opt/local/lib/libpng14.14.dylib @rpath/

pushd $SOURCE
git clean -fdx
NOCONFIGURE=1 ./autogen.sh
./configure CPP="cpp" CC="cc -mmacosx-version-min=10.5 -arch x86_64" $CONFIGURATION
echo .PHONY: all > perf/Makefile
echo .PHONY: all > perf/micro/Makefile
echo .PHONY: all > test/Makefile
echo .PHONY: all > test/pdiff/Makefile
echo .PHONY: all > doc/Makefile
echo .PHONY: all > doc/public/Makefile
make -j
popd
mv $SOURCE/$OBJDIR/$DYLIB $TARGET.64.tmp
install_name_tool -id @rpath/lib$PROJECT.dylib $TARGET.64.tmp
install_name_tool -change /opt/local/lib/libpixman-1.0.dylib @rpath/libpixman.dylib $TARGET.64.tmp

lipo -create $TARGET.*.tmp -output $TARGET
rm $TARGET.*.tmp

file $TARGET
otool -L $TARGET
size $TARGET
ls -l $TARGET

git --git-dir=$SOURCE/.git log -1 >> $TARGET

