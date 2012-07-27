set -e
pushd ../../../sdl
hg purge --all
hg checkout 6248 --clean
export SDK_PATH=`xcode-select --print-path`/Platforms/MacOSX.platform/Developer/SDKs
sed -i .bak "s/10\.[46]/10\.5/g" build-scripts/fatbuild.sh
build-scripts/fatbuild.sh
popd
mv ../../../sdl/build/.libs/libSDL-1.3.0.dylib ../../bin/OSX/sdl.dylib
install_name_tool -id @loader_path/sdl.dylib ../../bin/OSX/sdl.dylib
otool -L ../../bin/OSX/sdl.dylib
file ../../bin/OSX/sdl.dylib

