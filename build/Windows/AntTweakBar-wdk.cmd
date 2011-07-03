@echo off
setlocal

set _ROOT=%~dp0..\..
set _SRC=%_ROOT%\..\AntTweakBar\src
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

echo Compiling AntTweakBar: [_ARCH=%_ARCH%] [_TARGET=%_TARGET%] [_CROSS_TARGET=%_CROSS_TARGET%]
call %_WDK%\bin\setenv.bat %_WDK% fre %_CROSS_TARGET% win7 no_oacr

set LIB=%BASEDIR%\lib\crt\%_TARGET%;%BASEDIR%\lib\win7\%_TARGET%;%LIB%
set INCLUDE=%CRT_INC_PATH%;%INCLUDE%;
set INCLUDE=%SDK_INC_PATH%\crt\stl60;%INCLUDE%;

pushd %_SRC%
del link.cmd cl.cmd *.obj buildvm_*.h 1>nul 2>nul
rem echo cl.exe /D_MSC_VER=1399 %%* > cl.cmd
if "%_TARGET%"=="i386" (
   echo link.exe %_WDK%\lib\win7\%_TARGET%\msvcrt_win2000.obj %%* > link.cmd
)

set _OPTS=-O2 -Os -Oy -GF -GL -arch:SSE2 -MP
call cl -MD -FeAntTweakBar.dll -I%DXSDK_DIR%/Include -LD -nologo %_OPTS% -DTW_EXPORTS=1 -I../include LoadOGL.cpp LoadOGLCore.cpp TwBar.cpp TwColors.cpp TwEventSFML.cpp TwFonts.cpp TwMgr.cpp TwOpenGL.cpp TwDirect3D9.cpp TwDirect3D10.cpp TwDirect3D11.cpp user32.lib gdi32.lib kernel32.lib

del link.cmd cl.cmd 1>nul 2>nul
call :install AntTweakBar.dll %_ROOT%\bin\Windows\%_LUA_ARCH%
popd
goto :EOF

:install
echo install: [move /y %*]
move /y %*
goto :EOF
