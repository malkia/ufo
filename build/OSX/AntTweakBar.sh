ANT_TWEAK_BAR=../../../AntTweakBar
CXXCFG=-O1
GCC="clang -mmacosx-version-min=10.5"
echo ANT_TWEAK_BAR=$ANT_TWEAK_BAR GCC=$GCC

pushd $ANT_TWEAK_BAR/src
make -f Makefile.osx clean
make -j -f Makefile.osx CXXCFG="$CXXCFG" CXX="$GCC" LINK="$GCC"
popd

mv $ANT_TWEAK_BAR/lib/libAntTweakBar.dylib ../../bin/OSX/AntTweakBar.dylib
install_name_tool -id @loader_path/AntTweakBar.dylib ../../bin/OSX/AntTweakBar.dylib
otool -L ../../bin/OSX/AntTweakBar.dylib
file ../../bin/OSX/AntTweakBar.dylib
size ../../bin/OSX/AntTweakBar.dylib
ls -l ../../bin/OSX/AntTweakBar.dylib

