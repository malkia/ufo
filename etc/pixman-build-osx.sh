PIXMAN=../../pixman
pushd $PIXMAN
make clean
./configure CFLAGS="-O1 -arch i386 -arch x86_64" --disable-dependency-tracking
make -j
git log -1 >> ./pixman/.libs/libpixman-1.0.dylib 
mv ./pixman/.libs/libpixman-1.0.dylib ../ufo/bin/pixman.dylib
popd
