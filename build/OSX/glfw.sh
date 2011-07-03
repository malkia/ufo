export GLFW=../../glfw

pushd $GLFW

rm -rf build
mkdir build
pushd build
cmake -D CMAKE_OSX_DEPLOYMENT_TARGET=10.4 -D CMAKE_OSX_ARCHITECTURES="i386;x86_64" $GLFW
make -j8
popd

mv build/src/cocoa/libglfw.dylib glfw.dylib
rm -rf build

git log -1 >> glfw.dylib

popd

mv $GLFW/glfw.dylib ../bin/glfw.dylib

