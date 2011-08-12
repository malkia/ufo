@echo off
for /f %%i in ('cygpath -m %~dp0../../../android-ndk-r6') do set NDK=%%i

set NDKVER=%NDK%/toolchains/arm-linux-androideabi-4.4.3
set NDKP=%NDKVER%/prebuilt/windows/bin/arm-linux-androideabi-

set NDKABI=8
set NDKF=--sysroot %NDK%/platforms/android-%NDKABI%/arch-arm

make -C %~dp0..\..\..\luajit HOST_CC="gcc -m32" CROSS="%NDKP%" TARGET_FLAGS="%NDKF%" TARGET=arm TARGET_SYS=Linux HOST_RM=rm TARGET_SONAME=libluajit.so cleaner
make -C %~dp0..\..\..\luajit HOST_CC="gcc -m32" CROSS="%NDKP%" TARGET_FLAGS="%NDKF%" TARGET=arm TARGET_SYS=Linux HOST_RM=rm TARGET_SONAME=libluajit.so BUILDMODE=dynamic amalg %*

copy ..\..\..\luajit\src\libluajit.so ..\..\bin\Android\arm
copy ..\..\..\luajit\src\luajit       ..\..\bin\Android\arm

