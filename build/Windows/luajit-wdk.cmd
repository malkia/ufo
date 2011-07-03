@echo off
setlocal

set _ROOT=%~dp0..\..
set _SRC=%_ROOT%\..\luajit\src
set _ARCH=%1
set _WDK=%2

if "%_ARCH%"==""   set _ARCH=32
if "%_WDK%"==""    set _WDK=e:\apps\wdk
if "%_ARCH%"=="32" set _TARGET=i386
if "%_ARCH%"=="32" set _LUA_ARCH=x86
if "%_ARCH%"=="64" set _TARGET=amd64
if "%_ARCH%"=="64" set _LUA_ARCH=x64
if "%_TARGET%"=="" (
    echo You should specify 32 or 64 as first argument 
    goto :EOF
)

set _CROSS_TARGET=
if "%_TARGET%"=="amd64" set _CROSS_TARGET=x32-64

echo Compiling LuaJIT: [_ARCH=%_ARCH%] [_TARGET=%_TARGET%] [_CROSS_TARGET=%_CROSS_TARGET%]
call %_WDK%\bin\setenv.bat %_WDK% fre %_CROSS_TARGET% win7 no_oacr

set LIB=%BASEDIR%\lib\crt\%_TARGET%;%BASEDIR%\lib\win7\%_TARGET%;%LIB%
set INCLUDE=%CRT_INC_PATH%;%INCLUDE%;

pushd %_SRC%
del link.cmd cl.cmd *.obj buildvm_*.h 1>nul 2>nul
echo cl.exe /D_MSC_VER=1399 %%* > cl.cmd
if "%_TARGET%"=="i386" (
   echo link.exe %_WDK%\lib\win7\%_TARGET%\msvcrt_win2000.obj %%* > link.cmd
)
call msvcbuild amalg
del link.cmd cl.cmd 1>nul 2>nul
git log -1 >> lua51.dll
git log -1 >> luajit.exe
call :install lua51.dll  %_ROOT%\bin\Windows\%_LUA_ARCH%
call :install luajit.exe %_ROOT%\bin\Windows\%_LUA_ARCH%
popd
goto :EOF

:install
echo install: [move /y %*]
move /y %*
goto :EOF
