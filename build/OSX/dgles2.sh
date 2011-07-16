DGLES2=../../../gles-libs/dgles2
pushd $DGLES2
make distclean
./configure --disable-X11
ARCH=i386 CFLAGS="-arch i386 -mmacosx-version-min=10.4" LDFLAGS="-arch i386 -mmacosx-version-min=10.4 " make ARCH=i386
ARCH=x86_64 CFLAGS="-arch x86_64 -mmacosx-version-min=10.4 " LDFLAGS="-arch x86_64 -mmacosx-version-min=10.4 " make ARCH=x86_64
lipo -create -output libEGL.dylib    objs-i386/libEGL\.[0-9]*\.[0-9]*\.[0-9]*\.dylib    objs-x86_64/libEGL\.[0-9]*\.[0-9]*\.[0-9]*\.dylib
lipo -create -output libGLESv2.dylib objs-i386/libGLESv2\.[0-9]*\.[0-9]*\.[0-9]*\.dylib objs-x86_64/libGLESv2\.[0-9]*\.[0-9]*\.[0-9]*\.dylib
install_name_tool -id @rpath/libEGL.dylib libEGL.dylib
install_name_tool -id @rpath/libGLESv2.dylib libGLESv2.dylib
install_name_tool -change libEGL.1.dylib @rpath/libEGL.dylib libGLESv2.dylib
git log -1 >> libEGL.dylib
git log -1 >> libGLESv2.dylib
popd
cp $DGLES2/libEGL.dylib ../../bin/OSX
cp $DGLES2/libGLESv2.dylib ../../bin/OSX


