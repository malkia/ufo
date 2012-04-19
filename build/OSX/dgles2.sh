set -e

GLES_LIBS=../../../gles-libs
pushd $GLES_LIBS
git clean -fdx
pushd dgles2

./configure --disable-X11 --ARCH=i386
./configure --disable-X11 --ARCH=x86_64

make ARCH=i386 CC="clang -arch i386 -mmacosx-version-min=10.5"
make ARCH=x86_64 CC="clang -arch x86_64 -mmacosx-version-min=10.5"

lipo -create -output egl.dylib   `find objs-i386/libEGL\.[0-9]*\.[0-9]*\.[0-9]*\.dylib`    `find objs-x86_64/libEGL\.[0-9]*\.[0-9]*\.[0-9]*\.dylib`
lipo -create -output gles2.dylib `find objs-i386/libGLESv2\.[0-9]*\.[0-9]*\.[0-9]*\.dylib` `find objs-x86_64/libGLESv2\.[0-9]*\.[0-9]*\.[0-9]*\.dylib`
install_name_tool -id @loader_path/egl.dylib egl.dylib
install_name_tool -id @loader_path/gles2.dylib gles2.dylib
install_name_tool -change libEGL.1.dylib @loader_path/egl.dylib gles2.dylib
git log -1 >> egl.dylib
git log -1 >> gles2.dylib
popd
popd
cp $GLES_LIBS/dgles2/egl.dylib ../../bin/OSX
cp $GLES_LIBS/dgles2/gles2.dylib ../../bin/OSX

otool -L ../../bin/OSX/egl.dylib
otool -L ../../bin/OSX/gles2.dylib

