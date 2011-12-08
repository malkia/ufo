set -e

reldir=$(dirname $0)
pushd $reldir 1>/dev/null 2&>1 && absdir=$(pwd) && popd 1>/dev/null 2&>1

PROJECT=cairo
SRCDIR=../../../$PROJECT
OBJDIR=src/.libs
DYLIB=lib$PROJECT.2.dylib
TARGET=../../bin/OSX/$PROJECT.dylib

export pixman_LIBS="-Wl,$absdir/../../bin/OSX/pixman.dylib"
export pixman_CFLAGS=-I$absdir/../../../pixman/pixman

export png_LIBS="-Wl,$absdir/../../bin/OSX/png.dylib"
export png_CFLAGS="-I$absdir/../../../libpng"

export gl_LIBS=" -framework OpenGL "
export gl_CFLAGS="-I$absdir/include -framework OpenGL"

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
    --enable-quartz-image=no \
\
    --enable-gl=yes \
    --enable-quartz=yes \
    --enable-tee=yes \
    --enable-script=yes \
    --enable-png=yes \
    --enable-svg=yes \
    --enable-xml=yes \
"

pushd $SRCDIR
git clean -fdx
NOCONFIGURE=1 ./autogen.sh
./configure CPP="cpp" CC="cc -mmacosx-version-min=10.5 -arch i386 -D__LP64__=1" $CONFIGURATION
echo .PHONY: all > perf/Makefile
echo .PHONY: all > perf/micro/Makefile
echo .PHONY: all > test/Makefile
echo .PHONY: all > test/pdiff/Makefile
echo .PHONY: all > doc/Makefile
echo .PHONY: all > doc/public/Makefile
echo .PHONY: all > boilerplate/Makefile
make -j -C src
popd
mv $SRCDIR/$OBJDIR/$DYLIB $TARGET.32.tmp

pushd $SRCDIR
git clean -fdx
NOCONFIGURE=1 ./autogen.sh
./configure CPP="cpp" CC="cc -mmacosx-version-min=10.5 -arch x86_64" $CONFIGURATION
echo .PHONY: all > perf/Makefile
echo .PHONY: all > perf/micro/Makefile
echo .PHONY: all > test/Makefile
echo .PHONY: all > test/pdiff/Makefile
echo .PHONY: all > doc/Makefile
echo .PHONY: all > doc/public/Makefile
echo .PHONY: all > boilerplate/Makefile
make -j -C src
popd
mv $SRCDIR/$OBJDIR/$DYLIB $TARGET.64.tmp

lipo -create $TARGET.*.tmp -output $TARGET
rm $TARGET.*.tmp

install_name_tool -id @loader_path/$PROJECT.dylib $TARGET

file $TARGET
otool -L $TARGET
size $TARGET
ls -l $TARGET

git --git-dir=$SRCDIR/.git log -1 >> $TARGET

