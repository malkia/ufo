set -e
pushd ../../../sdl
hg purge --all
build-scripts/fatbuild.sh
popd
mv ../../../sdl/build/.libs/libSDL-1.3.0.dylib ../../bin/OSX/sdl.dylib
install_name_tool -id @rpath/sdl.dylib ../../bin/OSX/sdl.dylib
otool -L ../../bin/OSX/sdl.dylib
file ../../bin/OSX/sdl.dylib

