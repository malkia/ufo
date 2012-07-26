@echo off
pushd "%~dp0"
setlocal
git clean -fdx

for /f %%i in ('cygpath -m ../../../android-ndk-r8b') do set NDK=%%i

set NDKARCH=%1
if "%NDKARCH%"=="" set NDKARCH=arm

if /I "%NDKARCH%"=="arm"  set NDKTRIPLE1=arm-linux-androideabi
if /I "%NDKARCH%"=="arm"  set NDKTRIPLE2=arm-linux-androideabi
if /I "%NDKARCH%"=="arm"  set NDKMINABI=3

if /I "%NDKARCH%"=="mips" set NDKTRIPLE1=mipsel-linux-android
if /I "%NDKARCH%"=="mips" set NDKTRIPLE2=mipsel-linux-android
if /I "%NDKARCH%"=="mips" set NDKMINABI=9

if /I "%NDKARCH%"=="x86"  set NDKTRIPLE1=x86
rem if /I "%NDKARCH%"=="x86"  set NDKTRIPLE2=i686-android-linux
if /I "%NDKARCH%"=="x86"  set NDKTRIPLE2=i686-linux-android
if /I "%NDKARCH%"=="x86"  set NDKMINABI=9

rem set NDKVER=%NDK%/toolchains/%NDKTRIPLE1%-4.4.3
set NDKVER=%NDK%/toolchains/%NDKTRIPLE1%-4.6
set NDKP=%NDKVER%/prebuilt/windows/bin/%NDKTRIPLE2%-
set NDKABI=%NDKMINABI%
set NDKF=--sysroot %NDK%/platforms/android-%NDKABI%/arch-%NDKARCH%

echo NDKVER=[%NDKVER%]
echo NDKP=[%NDKP%]
echo NDKF=[%NDKF%]
echo NDKABI=[%NDKABI%]

make -C ..\..\..\luajit HOST_CC="gcc -m32" CROSS="%NDKP%" TARGET_FLAGS="%NDKF%" TARGET=%NDKARCH% TARGET_SYS=Linux HOST_RM=rm TARGET_SONAME=libluajit.so cleaner
make -C ..\..\..\luajit HOST_CC="gcc -m32" CROSS="%NDKP%" TARGET_FLAGS="%NDKF%" TARGET=%NDKARCH% TARGET_SYS=Linux HOST_RM=rm TARGET_SONAME=libluajit.so BUILDMODE=dynamic amalg

copy ..\..\..\luajit\src\libluajit.so ..\..\bin\android\%NDKARCH%
copy ..\..\..\luajit\src\luajit       ..\..\bin\android\%NDKARCH%

endlocal
popd
