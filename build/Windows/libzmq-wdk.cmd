@echo off
setlocal

set _ROOT=%~dp0..\..
set _SRC=%_ROOT%\..\glfw\src
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

echo Compiling glfw: [_ARCH=%_ARCH%] [_TARGET=%_TARGET%] [_CROSS_TARGET=%_CROSS_TARGET%]
call %_WDK%\bin\setenv.bat %_WDK% fre %_CROSS_TARGET% win7 no_oacr

set LIB=%BASEDIR%\lib\crt\%_TARGET%;%BASEDIR%\lib\win7\%_TARGET%;%LIB%
set INCLUDE=%CRT_INC_PATH%;%INCLUDE%;

pushd %_SRC%
del link.cmd cl.cmd *.obj buildvm_*.h 1>nul 2>nul
rem echo cl.exe /D_MSC_VER=1399 %%* > cl.cmd
if "%_TARGET%"=="i386" (
   echo link.exe %_WDK%\lib\win7\%_TARGET%\msvcrt_win2000.obj %%* > link.cmd
)

del config.h 1>nul 2>nul
copy /y "%~dpn0-config.h" config.h
set _FILES=enable.c error.c fullscreen.c gamma.c init.c input.c joystick.c opengl.c time.c window.c win32\win32_dllmain.c win32\win32_enable.c win32\win32_fullscreen.c 
set _FILES=%_FILES% win32\win32_gamma.c win32\win32_init.c win32\win32_joystick.c win32\win32_opengl.c win32\win32_time.c win32\win32_window.c 
set _OPTS=-O2 -Os -Oy -GF -GL -arch:SSE2 -MP
call cl -MD -Feglfw.dll -LD -DGLFW_BUILD_DLL=1 -nologo %_OPTS% -Iwin32 -I. %_FILES% ws2_32.lib rpcrt4.lib
del config.h 1>nul 2>nul

del link.cmd cl.cmd 1>nul 2>nul
git log -1 >> glfw.dll
call :install glfw.dll %_ROOT%\bin\Windows\%_LUA_ARCH%
popd
goto :EOF

:install
echo install: [move /y %*]
move /y %*
goto :EOF
