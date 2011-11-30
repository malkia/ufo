#!/bin/bash

set -e

#arm-none-linux-gnueabi-gcc -mcpu=arm1136jf-s -mfpu=vfp -mfloat-abi=softfp -I/opt/PalmPDK/include -I/opt/PalmPDK/include/SDL --sysroot=/opt/PalmPDK/arm-gcc/sysroot -L/opt/PalmPDK/device/lib -Wl,--allow-shlib-undefined -lSDL -lGLESv2 -lpdl -o Build_Device/simple ../src/simple.cpp

ROOT=../../../luajit
PDK=/opt/PalmPDK
PDKGCC=$PDK/arm-gcc

make -C $ROOT/src cleaner
make -C $ROOT/src -j amalg TARGET_SONAME=libluajit.so BUILDMODE=dynamic TARGET_DYNXLDOPTS=-Wl,-rpath,'$$\ORIGIN' Q= HOST_CC="gcc -m32" CROSS=$PDKGCC/bin/arm-none-linux-gnueabi- TARGET=arm TARGET_FLAGS="--sysroot $PDKGCC/sysroot" TARGET_SYS=Linux
mv      $ROOT/src/luajit       ../../bin/webOS
mv      $ROOT/src/libluajit.so ../../bin/webOS

