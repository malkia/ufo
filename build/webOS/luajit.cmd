@echo off
setlocal
rem set PDK="C:/Program Files (x86)/HP webOS/PDK"

set ROOT=..\..\..\luajit
set PATH=C:/Program Files (x86)/CodeSourcery/Sourcery G++ Lite/bin;%PATH%
pushd "%ROOT%" && git clean -fdx && make -j amalg LUAJIT_SO=luajit.so TARGET_SONAME=luajit.so BUILDMODE=dynamic TARGET_DYNXLDOPTS=-Wl,-rpath,'$$\ORIGIN' Q= CROSS=arm-none-linux-gnueabi- TARGET=arm TARGET_SYS=Linux CCDEBUG=-g && popd
move /y "%ROOT%\src\luajit"    "..\..\bin\webOS"
move /y "%ROOT%\src\luajit.so" "..\..\bin\webOS"



