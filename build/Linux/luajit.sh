#!/bin/bash
ROOT=../../../luajit


if [[ `uname -m` == armv* ]]; then
    make -C $ROOT/src clean
    make -C $ROOT/src -j amalg TARGET_SONAME=libluajit.so BUILDMODE=dynamic TARGET_DYNXLDOPTS=-Wl,-rpath,'$$\ORIGIN' Q=
    mv      $ROOT/src/luajit       ../../bin/Linux/arm
    mv      $ROOT/src/libluajit.so ../../bin/Linux/arm
else
    echo [Making 32-bit]
    make -C $ROOT/src clean
    make -C $ROOT/src -j amalg TARGET_SONAME=libluajit.so BUILDMODE=dynamic TARGET_DYNXLDOPTS=-Wl,-rpath,'$$\ORIGIN' Q= "CC=gcc -m32"
    mv      $ROOT/src/luajit       ../../bin/Linux/x86
    mv      $ROOT/src/libluajit.so ../../bin/Linux/x86
    
    echo [Making 64-bit]
    make -C $ROOT/src clean
    make -C $ROOT/src -j amalg TARGET_SONAME=libluajit.so BUILDMODE=dynamic TARGET_DYNXLDOPTS=-Wl,-rpath,'$$\ORIGIN' Q= "CC=gcc -m64"
    mv      $ROOT/src/luajit       ../../bin/Linux/x64
    mv      $ROOT/src/libluajit.so ../../bin/Linux/x64
fi


