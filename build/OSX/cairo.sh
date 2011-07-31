PROJECT=cairo
SOURCE=../../../$PROJECT
OBJDIR=src/.libs
DYLIB=lib$PROJECT.2.dylib
TARGET=../../bin/OSX/lib$PROJECT.dylib

CONFIGURATION="\
    --disable-silent-rules \
    --disable-dependency-tracking \
    --disable-static \
    --disable-xlib \
    --disable-xlib-xrender \
    --disable-xcb \
    --disable-xlib-xcb \
    --disable-xcb-shm \
    --disable-qt \
    --disable-png \
    --disable-interpreter \
    --disable-trace \
    --disable-xml \
    --disable-svg \
    --disable-pdf \
    --disable-ps \
    --disable-tee \
    --disable-script \
    --disable-quartz \
    --disable-ft \
    --disable-fc \
"

pushd $SOURCE
make clean
./configure CPP="cpp" CC="cc -mmacosx-version-min=10.4 -arch i386" $CONFIGURATION
make -j
popd
mv $SOURCE/$OBJDIR/$DYLIB $TARGET.32.tmp
install_name_tool -id @rpath/lib$PROJECT.dylib $TARGET.32.tmp
install_name_tool -change /opt/local/lib/libpixman-1.0.dylib @rpath/libpixman.dylib $TARGET.32.tmp

pushd $SOURCE
make clean
./configure CPP="cpp" CC="cc -mmacosx-version-min=10.4 -arch x86_64" $CONFIGURATION
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

