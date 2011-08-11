#!/bin/bash
ROOT=../../../luajit

make -C $ROOT/src cleaner

if [[ `uname -m` == armv* ]]; then
    make -C $ROOT/src -j amalg TARGET_SONAME=libluajit.so BUILDMODE=dynamic
    mv      $ROOT/src/luajit       ../../bin/Linux/arm
    mv      $ROOT/src/libluajit.so ../../bin/Linux/arm
else
    make -C $ROOT/src cleaner
    make -C $ROOT/src -j amalg TARGET_SONAME=libluajit.so BUILDMODE=dynamic "CC=gcc -m32"
    mv      $ROOT/src/luajit       ../../bin/Linux/x86
    mv      $ROOT/src/libluajit.so ../../bin/Linux/x86
    
    make -C $ROOT/src cleaner
    make -C $ROOT/src -j amalg TARGET_SONAME=libluajit.so BUILDMODE=dynamic "CC=gcc -m64"
    mv      $ROOT/src/luajit       ../../bin/Linux/x64
    mv      $ROOT/src/libluajit.so ../../bin/Linux/x64
fi


