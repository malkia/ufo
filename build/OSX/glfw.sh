GLFW=../../../glfw

pushd $GLFW
git clean -fdx

mkdir build
pushd build
cmake -D CMAKE_OSX_DEPLOYMENT_TARGET=10.5 -D CMAKE_OSX_ARCHITECTURES="i386;x86_64" ../
make -j8
popd

git log -1 >> build/src/libglfw.dylib
popd

mv $GLFW/build/src/libglfw.dylib ../../bin/OSX/

install_name_tool -id @rpath/libglfw.dylib ../../bin/OSX/libglfw.dylib
otool -L ../../bin/OSX/libglfw.dylib
file ../../bin/OSX/libglfw.dylib


