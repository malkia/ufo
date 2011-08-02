@echo off
rem LB_ROOT points to the root folder of this distribution
rem
if "%LB_ROOT%"=="" set LB_ROOT=%~dp0..\..\..

rem LB_PROJECT_NAME is the name of the project to be build
rem LB_PROJECT_ROOT is the location of the project to be build
rem
if "%LB_PROJECT_NAME%"=="" set LB_PROJECT_NAME=%1
if "%LB_PROJECT_ROOT%"=="" set LB_PROJECT_ROOT=%LB_ROOT%\..\%LB_PROJECT_NAME%

rem LB_TARGET_ARCH is the architecture we are building for (from %1 by default)
rem
if "%LB_TARGET_BITS%"=="" set LB_TARGET_BITS=%2
if "%LB_TARGET_BITS%"=="" set LB_TARGET_BITS=32
if "%LB_TARGET_ARCH%"=="" if "%LB_TARGET_BITS%"=="32" set LB_TARGET_ARCH=x86
if "%LB_TARGET_ARCH%"=="" if "%LB_TARGET_BITS%"=="64" set LB_TARGET_ARCH=x64

rem LB_TARGET_BUILD would be set to the native compiler
rem LB_TARGET_CROSS would be set to the cross compiler
rem
if "%LB_TARGET_BUILD%"=="" if "%LB_TARGET_ARCH%"=="x86"    set LB_TARGET_BUILD=i386
if "%LB_TARGET_BUILD%"=="" if "%LB_TARGET_ARCH%"=="x64"    set LB_TARGET_BUILD=amd64
if "%LB_TARGET_CROSS%"=="" if "%LB_TARGET_BUILD%"=="amd64" set LB_TARGET_CROSS=x32-64

rem LB_WDK_ROOT (from %2 by default)
rem
if "%LB_WDK_ROOT%"=="" set LB_WDK_ROOT=%3
if "%LB_WDK_ROOT%"=="" set LB_WDK_ROOT=e:\apps\wdk

echo LB: Project NAME=%LB_PROJECT_NAME% ROOT=%LB_PROJECT_ROOT%
echo LB:  Target ARCH=%LB_TARGET_ARCH% BUILD=%LB_TARGET_BUILD% CROSS=%LB_TARGET_CROSS%
call %LB_WDK_ROOT%\bin\setenv.bat %LB_WDK_ROOT% fre %LB_TARGET_CROSS% win7 no_oacr

set LIB=%BASEDIR%\lib\crt\%LB_TARGET_BUILD%;%BASEDIR%\lib\win7\%LB_TARGET_BUILD%;%LIB%
set INCLUDE=%CRT_INC_PATH%;%SDK_INC_PATH%\crt\stl60;%INCLUDE%;

set LB_OBJS=
set LB_CUTSYMPOS=49
if "%LB_TARGET_ARCH%"=="x86" (
   set LB_OBJS=msvcrt_win2000.obj
   set LB_CUTSYMPOS=50
)

cd /d %~dp0
