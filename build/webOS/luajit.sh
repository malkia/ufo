#!/bin/bash

set -e

ROOT=../../../luajit
PDK=/opt/PalmPDK
PDKGCC=$PDK/arm-gcc

make -C $ROOT/src cleaner
make -C $ROOT/src -j amalg TARGET_SONAME=libluajit.so BUILDMODE=dynamic TARGET_DYNXLDOPTS=-Wl,-rpath,'$$\ORIGIN' Q= HOST_CC="gcc -m32" CROSS=$PDKGCC/bin/arm-none-linux-gnueabi- TARGET=arm TARGET_FLAGS="--sysroot $PDKGCC/sysroot" TARGET_SYS=Linux
mv      $ROOT/src/luajit       ../../bin/webOS
mv      $ROOT/src/libluajit.so ../../bin/webOS

