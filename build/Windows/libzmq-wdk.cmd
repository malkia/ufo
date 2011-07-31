@echo off
SetLocal EnableExtensions EnableDelayedExpansion

set _ROOT=%~dp0..\..
set _SRC=%_ROOT%\..\libzmq\src
set _TGT=zmq.dll
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

echo Making: %_TGT% 
echo Source: %_SRC%
echo Target: _ARCH=%_ARCH% _TARGET=%_TARGET% _CROSS_TARGET=%_CROSS_TARGET%
echo.
call %_WDK%\bin\setenv.bat %_WDK% fre %_CROSS_TARGET% win7 no_oacr

set LIB=%BASEDIR%\lib\crt\%_TARGET%;%BASEDIR%\lib\win7\%_TARGET%;%LIB%
set INCLUDE=%CRT_INC_PATH%;%INCLUDE%;
set INCLUDE=%SDK_INC_PATH%\crt\stl60;%INCLUDE%;

pushd %_SRC%
set _OPTS=-DWINDOWS
if "%_TARGET%"=="i386" (
   set _OPTS=%_OPTS% -arch:SSE2
   set _FILES=%_WDK%\lib\win7\%_TARGET%\msvcrt_win2000.obj
)

for /F %%i in (%~dp0..\source\zmq.files) do set _FILES=!_FILES! %%i

set _OPTS=%_OPTS% -O2 -Os -Oi -Ob2 -Oy -GF -GL -MP -DNDEBUG=1
call cl -GL -EHsc -MD -Fe%_TGT% -LD -DDLL_EXPORT=1 -nologo %_OPTS% -Iwin32 -I. -I..\builds\msvc -I%~dp0 -DNOMINMAX -FI%~dpn0-missing.h %_FILES% /link"/LTCG /RELEASE /SWAPRUN:NET ws2_32.lib rpcrt4.lib"
del config.h 1>nul 2>nul

git log -1 >> %_TGT%
call :install %_TGT% %_ROOT%\bin\Windows\%_LUA_ARCH%
popd
goto :EOF

:install
echo install: [move /y %*]
move /y %*
goto :EOF
