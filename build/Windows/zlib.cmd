@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
setlocal

rem ZLIB usually comes precompiled as tarball
rem I put it at ../../../zlib, and did this in it:
rem git init
rem git add *
rem git commit -a -m "initial"
rem
rem Now git is used to clean object files
rem
git clean -fdx

if "%LB_TARGET_ARCH%"=="x86" set OBJA=inffas32.obj match686.obj
if "%LB_TARGET_ARCH%"=="x86" set AS=ml
if "%LB_TARGET_ARCH%"=="x64" set OBJA=inffasx64.obj gvmat64.obj inffas8664.obj
if "%LB_TARGET_ARCH%"=="x64" set AS=ml64
set NAME=%LB_PROJECT_NAME%

nmake -f win32/Makefile.msc^
      CC="cl -I. %LB_CL_OPTS%"^
      SHAREDLIB="zlib.dll" OBJA="%OBJA%" AS="%AS%" LOC="-DASMV -DASMINF"^
      AR="link /LIB"^
      LD="link %LB_LINK_OPTS%"

move /y zdll.lib %NAME%.lib

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd

