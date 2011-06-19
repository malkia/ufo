@echo off

setlocal

set _ARCH=%1
if "%_ARCH%"=="" set _ARCH=32

set _WDK=%2
if "%_WDK%"=="" set _WDK=c:\wdk

set _LUAJITDIR=%~dp0..\..\luajit\src
set _UFODIR=%~dp0..

if "%_ARCH%"=="32" set _TARGET=i386
if "%_ARCH%"=="64" set _TARGET=amd64
if "%_TARGET%"=="" goto :INVALID_ARCH

set _CROSS_TARGET=
if "%_TARGET%"=="amd64" set _CROSS_TARGET=x32-64

echo Compiling LuaJIT: [_ARCH=%_ARCH%] [_TARGET=%_TARGET%] [_CROSS_TARGET=%_CROSS_TARGET%]
call %_WDK%\bin\setenv.bat %_WDK% fre %_CROSS_TARGET% WIN7 no_oacr

set LIB=%BASEDIR%\lib\crt\%_TARGET%;%BASEDIR%\lib\win7\%_TARGET%;
set INCLUDE=%CRT_INC_PATH%;%INCLUDE%;

pushd
cd /d %_LUAJITDIR%
for %%j in (amalg static) do (
  call %~dp0\luajit-build-windows-mt.bat %%j
  if "%%j"=="amalg" (
    call :echo move /y %_LUAJITDIR%\lua51.dll  %_UFODIR%\bin\luajit%_ARCH%.dll
    git log -1 >> %_UFODIR%\bin\luajit%_ARCH%.dll
  )
  if "%%j"=="static" (
    call :echo move /y %_LUAJITDIR%\luajit.exe      %_UFODIR%\luajit%_ARCH%.exe
    git log -1 >> %_UFODIR%\luajit%_ARCH%.exe
  )
rem  staticlib echo move /y %_LUAJITDIR%\lua51.lib %_UFODIR%\bin\luajit%_ARCH%.lib
rem  dynamiclib echo move /y %_LUAJITDIR%\luajit.lib %_UFODIR%\bin\luajit%_ARCH%.lib
)
popd

goto :EOF

:INVALID_ARCH
echo You should specifiy 32 or 64 as first argument
goto :EOF

:echo
echo [%*]
%*
goto :EOF
