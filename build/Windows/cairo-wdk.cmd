@echo off
setlocal EnableExtensions EnableDelayedExpansion

set PROJECT=cairo

set _ROOT=%~dp0..\..
set _SRC=%_ROOT%\..\%PROJECT%
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

echo Compiling %PROJECT%: [_ARCH=%_ARCH%] [_TARGET=%_TARGET%] [_CROSS_TARGET=%_CROSS_TARGET%]
call %_WDK%\bin\setenv.bat %_WDK% fre %_CROSS_TARGET% win7 no_oacr

set LIB=%BASEDIR%\lib\crt\%_TARGET%;%BASEDIR%\lib\win7\%_TARGET%;%LIB%
set INCLUDE=%CRT_INC_PATH%;%INCLUDE%;

set OBJS=
set CUTSYMPOS=49
if "%_TARGET%"=="i386" (
   set OBJS="msvcrt_win2000.obj"
   set CUTSYMPOS=50
)

pushd %_SRC%
git clean -fdx
copy /y %~dpn0.features build\Makefile.win32.features
rem copy /y ..\pixman\pixman%_LUA_ARCH%.lib ..\pixman\pixman\release\pixman-1.lib
copy /y ..\pixman\pixman.lib ..\pixman\pixman\release\pixman-1.lib
make -f Makefile.win32 CFG=release AR="link /LIB" LD="link %OBJS%"
git log -1 >> src/release/%PROJECT%.dll
call :install src\release\%PROJECT%.dll %_ROOT%\bin\Windows\%_LUA_ARCH%
popd
goto :EOF

:install
echo install: [move /y %*]
move /y %*
goto :EOF
