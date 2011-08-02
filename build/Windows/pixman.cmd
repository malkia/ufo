@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
setlocal

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=50
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=49

if not exist configure sh -c ./autogen.sh

set NAME=%LB_PROJECT_NAME%.%LB_TARGET_ARCH%

del *.obj /s
make -k MMX=off -C pixman -f Makefile.win32 CFG=release
link /LIB /MACHINE:%LB_TARGET_ARCH% pixman\release\*.obj /OUT:%NAME%_static.lib

rem echo LIBRARY %LB_PROJECT_NAME% > %NAME%.def
echo EXPORTS >> %NAME%.def
link /DUMP /symbols /exports %NAME%_static.lib | grep " notype ()    External " | grep " SECT"  | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def

link /MACHINE:%LB_TARGET_ARCH% /OUT:%NAME%.dll /DEF:%NAME%.def /DLL /RELEASE /SWAPRUN:NET /SWAPRUN:CD %LB_OBJS% %NAME%_static.lib
move /y %NAME%.dll %LB_PROJECT_NAME%.dll

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
endlocal
popd
