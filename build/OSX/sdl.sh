pushd ../../../sdl
hg purge --all
build-scripts/fatbuild.sh
popd
cp ../../../sdl/build/.libs/libSDL-1.3.0.dylib ../../bin/OSX/libSDL.dylib
otool -L ../../bin/OSX/libSDL.dylib
file ../../bin/OSX/libSDL.dylib
install_name_tool -id @rpath/libSDL.dylib ../../bin/OSX/libSDL.dylib
