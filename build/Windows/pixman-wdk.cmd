@echo off
setlocal EnableExtensions EnableDelayedExpansion

set PROJECT=pixman

set _ROOT=%~dp0..\..
set _SRC=%_ROOT%\..\pixman
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

echo Compiling pixman: [_ARCH=%_ARCH%] [_TARGET=%_TARGET%] [_CROSS_TARGET=%_CROSS_TARGET%]
call %_WDK%\bin\setenv.bat %_WDK% fre %_CROSS_TARGET% win7 no_oacr

set LIB=%BASEDIR%\lib\crt\%_TARGET%;%BASEDIR%\lib\win7\%_TARGET%;%LIB%
set INCLUDE=%CRT_INC_PATH%;%INCLUDE%;

set OBJS=
set CUTSYMPOS=49
if "%_TARGET%"=="i386" (
   set OBJS="%_WDK%\lib\win7\%_TARGET%\msvcrt_win2000.obj"
   set CUTSYMPOS=50
)

pushd %_SRC%
if not exist configure then sh -c ./autogen.sh
make MMX=off -C pixman -f Makefile.win32 clean
del pixman\release\*.obj
make -k MMX=off -C pixman -f Makefile.win32
echo LIBRARY PIXMAN > pixman%_LUA_ARCH%.def
echo EXPORTS >> pixman%_LUA_ARCH%.def
del pixman.lib
link /LIB /MACHINE:%_LUA_ARCH% pixman\release\*.obj /OUT:pixman%_LUA_ARCH%.lib
rem nm pixmanx86.lib | grep " T " | cut -b13- >> pixman%_LUA_ARCH%.def
link /DUMP /symbols /exports pixman%_LUA_ARCH%.lib | grep " notype ()    External " | grep " SECT"  | cut -b%CUTSYMPOS%- | sort | uniq >> pixman%_LUA_ARCH%.def
link /MACHINE:%_LUA_ARCH% /OUT:pixman.dll /DEF:pixman%_LUA_ARCH%.def /DLL %OBJS% pixman%_LUA_ARCH%.lib
git log -1 >> %PROJECT%.dll
call :install %PROJECT%.dll %_ROOT%\bin\Windows\%_LUA_ARCH%
popd
goto :EOF

:install
echo install: [move /y %*]
move /y %*
goto :EOF
