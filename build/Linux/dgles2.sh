# git://gitorious.org/qemu-maemo/gles-libs.git
SRC=../../../gles-libs/dgles2
CFG="--disable-osmesa --enable-glx --prefix='./'"
O32=./objs-i686
O64=./objs-x86_64
D32=../../bin/Linux/x86
D64=../../bin/Linux/x64
SRC_EGL=libEGL.so.1.4.2
DST_EGL=libEGL.so.1
SRC_GLES2=libGLESv2.so.2.0.0
DST_GLES2=libGLESv2.so
pushd $SRC
make clean && linux32 ./configure $CFG && linux32 make -j CC="cc -m32"
make clean && linux64 ./configure $CFG && linux64 make -j CC="cc -m64"
strip $O32/$SRC_EGL
strip $O32/$SRC_GLES2
strip $O64/$SRC_EGL
strip $O64/$SRC_GLES2
git log -1 >> $O32/$SRC_EGL
git log -1 >> $O32/$SRC_GLES2
git log -1 >> $O64/$SRC_EGL
git log -1 >> $O64/$SRC_GLES2
popd
cp $SRC/$O32/$SRC_EGL   $D32/$DST_EGL
cp $SRC/$O32/$SRC_GLES2 $D32/$DST_GLES2
cp $SRC/$O64/$SRC_EGL   $D64/$DST_EGL
cp $SRC/$O64/$SRC_GLES2 $D64/$DST_GLES2
