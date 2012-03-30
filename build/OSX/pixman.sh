set -e

PROJECT=pixman
SRCDIR=../../../$PROJECT
TARGET=../../bin/OSX/$PROJECT.dylib

pushd $SRCDIR
git clean -fdx
./autogen.sh CPP="cpp" CC="gcc -arch i386 -arch x86_64 -mmacosx-version-min=10.5" --disable-dependency-tracking --disable-gtk --enable-gtk=no --disable-timers --disable-static-testprogs
make -j
popd
mv $SRCDIR/$PROJECT/.libs/lib$PROJECT-1.0.dylib $TARGET

install_name_tool -id @loader_path/$PROJECT.dylib $TARGET
file $TARGET
otool -L $TARGET
size $TARGET
ls -l $TARGET

git --git-dir=$SRCDIR/.git log -1 >> $TARGET

