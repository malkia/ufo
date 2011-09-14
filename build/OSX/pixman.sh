PROJECT=pixman
SOURCE=../../../$PROJECT
OBJDIR=$PROJECT/.libs
DYLIB=lib$PROJECT-1.0.dylib
TARGET=../../bin/OSX/lib$PROJECT.dylib

pushd $SOURCE
git clean -fdx
./autogen.sh CPP="cpp" CC="cc -arch i386 -arch x86_64 -mmacosx-version-min=10.5" --disable-dependency-tracking --disable-gtk --enable-gtk=no --disable-timers --disable-static-testprogs
make -j
popd
mv $SOURCE/$OBJDIR/$DYLIB $TARGET

install_name_tool -id @rpath/lib$PROJECT.dylib $TARGET
file $TARGET
otool -L $TARGET
size $TARGET
ls -l $TARGET

git --git-dir=$SOURCE/.git log -1 >> $TARGET

