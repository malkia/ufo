set -e

PROJECT=png
SRCDIR=../../../lib$PROJECT
SOURCE=$SRCDIR/.libs/lib"$PROJECT"15.15.dylib
TARGET=../../bin/OSX/$PROJECT.dylib

pushd $SRCDIR
git clean -fdx
./configure CPP="cpp" CC="cc -arch i386 -arch x86_64 -mmacosx-version-min=10.5" --disable-dependency-tracking
make -j
popd
mv $SOURCE $TARGET

install_name_tool -id @loader_path/$PROJECT.dylib $TARGET
file $TARGET
otool -L $TARGET
size $TARGET
ls -l $TARGET

git --git-dir=$SRCDIR/.git log -1 >> $TARGET

