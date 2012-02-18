set -e

GLFW=../../../glfw

pushd $GLFW
git clean -fdx

mkdir build
pushd build
cmake -D CMAKE_OSX_DEPLOYMENT_TARGET=10.5 -D CMAKE_OSX_ARCHITECTURES="i386;x86_64" -D CMAKE_C_COMPILER=clang -D CMAKE_OSX_SYSROOT="`xcode-select -print-path`/SDKs/MacOSX10.5.sdk" ../
make -j
popd

git log -1 >> build/src/libglfw.dylib
popd

mv $GLFW/build/src/libglfw.dylib ../../bin/OSX/glfw.dylib

install_name_tool -id @loader_path/glfw.dylib ../../bin/OSX/glfw.dylib
otool -L ../../bin/OSX/glfw.dylib
file ../../bin/OSX/glfw.dylib


