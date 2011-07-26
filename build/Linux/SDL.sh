export SRC=../../../sdl
export TGT=build/.libs/libSDL-1.3.so.0.0.0
export CFG="--enable-ssemath --enable-sse2 --disable-alsatest --disable-esdtest --enable-video-directfb --enable-fusionsound"
export CFLAGS=-O1
rm -rf sdl32 && mkdir sdl32 && pushd sdl32 && ../$SRC/configure $CFG CC="gcc -m32" && make -j && popd && strip sdl32/$TGT && hg -R $SRC log -l 1 >> sdl32/$TGT && cp sdl32/$TGT ../../bin/Linux/x86/libSDL.so && rm -rf sdl32
rm -rf sdl64 && mkdir sdl64 && pushd sdl64 && ../$SRC/configure $CFG CC="gcc -m64" && make -j && popd && strip sdl64/$TGT && hg -R $SRC log -l 1 >> sdl64/$TGT && cp sdl64/$TGT ../../bin/Linux/x64/libSDL.so && rm -rf sdl64
