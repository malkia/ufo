@echo off
setlocal
set BBNDK=c:\bbndk-2.0.0
call %BBNDK%\bbndk-env.bat
echo %PATH%

set ROOT=..\..\..\luajit
rem Add Q= to be more verbose
pushd "%ROOT%" && git clean -fdx && make -j amalg HOST_CC="i686-w64-mingw32-gcc -m32" LUAJIT_SO=luajit.so TARGET_SONAME=luajit.so BUILDMODE=dynamic TARGET_DYNXLDOPTS=-Wl,-rpath,'$$\ORIGIN' CROSS=ntoarmv7- TARGET=arm TARGET_SYS=Other CCDEBUG=-g && popd
move /y "%ROOT%\src\luajit"    "..\..\bin\bbx"
move /y "%ROOT%\src\luajit.so" "..\..\bin\bbx"



