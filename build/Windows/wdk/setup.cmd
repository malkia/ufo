@echo off

rem LB -- Lua Build helper for Windows DDK
rem
rem LB_ROOT         - The root of the distribution (default: <this-batch-file-directory>/../../../)
rem LB_PROJECT_NAME - Name of a project that we want to compile
rem LB_PROJECT_ROOT - The root of the project above that we want to compile (default: %LB_ROOT%/../%LB_PROJECT_NAME%)
rem LB_TARGET_BITS  - 32 or 64 (default: 32)
rem LB_TARGET_ARCH  - x86, x64, arm (default: x86)
rem LB_TARGET_CPU   - i386, amd64, armv7l (default: i386)
rem LB_TARGET_CROSS - x32-64 (default: empty)
rem LB_WDK_ROOT     - The Windows DDK Root. It's detected by looking at the ftype GraphEdtGraph



rem LB_ROOT points to the root of the distribution.
rem    By default that's three directories up from this batch file.
rem    To override it, set it before calling the batch file.
rem
if "%LB_ROOT%"=="" set LB_ROOT=%~dp0/../../../
for %%i in ("%LB_ROOT%/") do set LB_ROOT=%%~dpi



rem LB_PROJECT_NAME is the name of the project to be build.
rem    By default that's the first parameter (%1) provided to this batch file.
rem    To override it, set it before calling this batch file, and don't provide
rem    anything as first parameter
rem                 
if "%LB_PROJECT_NAME%"=="" set LB_PROJECT_NAME=%1

rem LB_PROJECT_ROOT points to the root of the project to be build.
rem    By default the root is set to be a sibling of the distribution root,
rem    named with value provided by LB_PROJECT_NAME
rem    If the name is the same as the distribution, it might simply be used
rem    to recompile internal to the disribution project
rem    To override it, set it before calling this batch file.
rem
if "%LB_PROJECT_ROOT%"=="" set LB_PROJECT_ROOT=%LB_ROOT%\..\%LB_PROJECT_NAME%
for %%i in ("%LB_PROJECT_ROOT%/") do set LB_PROJECT_ROOT=%%~dpi



rem LB_TARGET_BITS specifies 32-bit or 64-bit target mode for the build.
rem    By default that's the second parameter (%2) provided to this batch file
rem    If the parameter is omit, it's set to 32-bit
rem    Valid values are: 32 and 64
rem    To override it, set it before callng this batch file
rem
if "%LB_TARGET_BITS%"=="" set LB_TARGET_BITS=%2
if "%LB_TARGET_BITS%"=="" set LB_TARGET_BITS=32

rem LB_TARGET_ARCH specifies target architecture for the project to be build.
rem    By default the name is interpreted from the value of TARGET_BITS
rem    For 32-bits it's set to x86, and 64-bits to x64
rem    This matches LuaJIT's ffi.arch and jit.arch
rem    To override it, set it before calling this batch file.
rem
if "%LB_TARGET_ARCH%"=="" if "%LB_TARGET_BITS%"=="32" set LB_TARGET_ARCH=x86
if "%LB_TARGET_ARCH%"=="" if "%LB_TARGET_BITS%"=="64" set LB_TARGET_ARCH=x64
if "%LB_TARGET_ARCH%"=="" goto :bad-arch

rem LB_TARGET_CPU would be set to the native compiler
rem
if "%LB_TARGET_CPU%"=="" if "%LB_TARGET_ARCH%"=="x86" set LB_TARGET_CPU=i386
if "%LB_TARGET_CPU%"=="" if "%LB_TARGET_ARCH%"=="x64" set LB_TARGET_CPU=amd64
if "%LB_TARGET_CPU%"=="" goto :bad-cpu

rem LB_TARGET_CROSS would be set to the cross compiler
rem
if "%LB_TARGET_CROSS%"=="" if "%LB_TARGET_CPU%"=="amd64" set LB_TARGET_CROSS=x32-64



rem LB_WDK_ROOT (from %3 by default)
rem
if "%LB_WDK_ROOT%"=="" set LB_WDK_ROOT=%3
if "%LB_WDK_ROOT%"=="" for /F "tokens=2 delims==" %%i in ('ftype GraphEdtGraph') do set LB_WDK_ROOT=%%~dpi/../../../
if "%LB_WDK_ROOT%"=="" set LB_WDK_ROOT=e:\apps\wdk
for %%i in ("%LB_WDK_ROOT%/") do set LB_WDK_ROOT=%%~dpi

if "%LB_WDK_ROOT%"=="" goto :wdk-not-found
if not exist "%LB_WDK_ROOT%/bin/setenv.bat" goto :wdk-not-found

echo LB: PROJECT: NAME=%LB_PROJECT_NAME% ROOT=%LB_PROJECT_ROOT%
echo LB: TARGET:  ARCH=%LB_TARGET_ARCH% CPU=%LB_TARGET_CPU% CROSS=%LB_TARGET_CROSS%
call %LB_WDK_ROOT%\bin\setenv.bat %LB_WDK_ROOT% fre %LB_TARGET_CROSS% win7 no_oacr
cd /d %~dp0..

set LIB=%BASEDIR%\lib\crt\%LB_TARGET_CPU%;%BASEDIR%\lib\win7\%LB_TARGET_CPU%;%LIB%
set INCLUDE=%CRT_INC_PATH%;%SDK_INC_PATH%\crt\stl60;%INCLUDE%;

if "%LB_TARGET_ARCH%"=="x86" set LB_OBJS=msvcrt_win2000.obj
if "%LB_TARGET_ARCH%"=="x64" set LB_OBJS=msvcrt_win2003.obj

if "%LB_CL_ARCH_SSE2%"=="" if "%LB_TARGET_BITS%"=="32" set LB_CL_ARCH_SSE2=/arch:SSE2
if "%LB_CL_ARCH_SSE2%"=="" if "%LB_TARGET_BITS%"=="64" set LB_CL_ARCH_SSE2=

set PATH=%~dp0..\bin;%PATH%

del %~dp0\bin\cl.cmd %~dp0\bin\link.cmd 1>nul 2>nul

if "%LB_LINK_SWAPRUN%"=="" set LB_LINK_SWAPRUN=-SWAPRUN:NET,CD

if "%LB_CL_OPTS%"==""   set LB_CL_OPTS=/nologo -MD -GL -O2 -GS- -Zi -Qfast_transcendentals -Fd%LB_PROJECT_NAME%.pdb %LB_CL_ARCH_SSE2% -wd4005
if "%LB_LINK_OPTS%"=="" set LB_LINK_OPTS=-NOLOGO -DEBUG -OPT:REF -OPT:ICF=9999 -DYNAMICBASE:NO -DLL -LTCG -MACHINE:%LB_TARGET_ARCH% %LB_LINK_SWAPRUN% -PDB:%LB_PROJECT_NAME%.pdb -NXCOMPAT:NO %LB_OBJS%

goto :EOF

:wdk-not-found
echo LB: ERROR: %0 - Windows DDK (WDK) cannot be located
echo LB: ERROR: %0 - You can force it's location by setting LB_WDK_ROOT
echo LB: ERROR: %0 - For example LB_WDK_ROOT=c:\wdk
goto :EOF

:bat-bits
:bad-arch
:bad-cpu
:bad-cross
echo LB: ERROR: Something bad happened!
goto :EOF
