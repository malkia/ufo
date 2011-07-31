PROJECT=pixman
SOURCE=../../../$PROJECT
OBJDIR=$PROJECT/.libs
DYLIB=lib$PROJECT-1.0.dylib
TARGET=../../bin/OSX/lib$PROJECT.dylib

pushd $SOURCE
make clean
./configure CFLAGS="-Os -arch i386 -arch x86_64 -mmacosx-version-min=10.4" --disable-dependency-tracking --disable-static --disable-gtk
make -j
git log -1 >> $OBJDIR/$DYLIB
popd
mv $SOURCE/$OBJDIR/$DYLIB $TARGET

install_name_tool -id @rpath/lib$PROJECT.dylib $TARGET
file $TARGET
otool -L $TARGET
size $TARGET
ls -l $TARGET
