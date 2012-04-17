#!/bin/bash

set -e

ROOT=../../../luajit
BBNDK=/opt/bbndk-2.0.0/

make -C $ROOT/src cleaner
make -C $ROOT/src -j amalg LUAJIT_SO=luajit.so TARGET_SONAME=luajit.so BUILDMODE=dynamic TARGET_DYNXLDOPTS=-Wl,-rpath,'$$\ORIGIN' Q= HOST_CC="gcc -m32" CROSS=ntoarmv7- TARGET=arm TARGET_SYS=Other
mv      $ROOT/src/luajit    ../../bin/bbx
mv      $ROOT/src/luajit.so ../../bin/bbx

