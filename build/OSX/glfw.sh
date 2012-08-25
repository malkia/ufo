set -e
GLFW=../../../glfw

pushd $GLFW
git clean -fdx

mkdir build
cd build

# http://stackoverflow.com/questions/1440456/static-libraries-in-version-cross-compiled-program/7835983#7835983
export MACOSX_DEPLOYMENT_TARGET=10.5
cmake -D CMAKE_OSX_ARCHITECTURES="i386;x86_64" -D BUILD_SHARED_LIBS=ON -D CMAKE_C_COMPILER=clang ../
make -j VERBOSE=1

git log -1 >> src/libglfw.3.0.dylib
popd

mv $GLFW/build/src/libglfw.3.0.dylib ../../bin/OSX/glfw.dylib
install_name_tool -id @loader_path/glfw.dylib ../../bin/OSX/glfw.dylib
otool -L ../../bin/OSX/glfw.dylib
file ../../bin/OSX/glfw.dylib

