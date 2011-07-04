#!/bin/bash
SRC=../../../luajit/src
make -C $SRC cleaner
make -C $SRC -j amalg TARGET_SONAME=libluajit.so BUILDMODE=dynamic

