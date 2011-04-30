export ANT_TWEAK_BAR=../../AntTweakBar
export GCC="gcc -mmacosx-version-min=10.4"
echo ANT_TWEAK_BAR=$ANT_TWEAK_BAR GCC=$GCC

pushd $ANT_TWEAK_BAR/src
make -f Makefile.osx clean
make -j8 -f Makefile.osx CXX="$GCC" LINK="$GCC"
popd

mv $ANT_TWEAK_BAR/lib/libAntTweakBar.dylib ../bin/AntTweakBar.dylib
