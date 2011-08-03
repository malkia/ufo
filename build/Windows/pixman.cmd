@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
setlocal

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=50
if "%LB_TARGET_BITS%"=="32" set MMX=on
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=49
if "%LB_TARGET_BITS%"=="64" set MMX=off

if not exist configure sh -c ./autogen.sh

set NAME=%LB_PROJECT_NAME%

del *.def *.exp *.obj *.lib /s
make -k MMX=%MMX% -C pixman -f Makefile.win32 CFG=release
link /LIB /MACHINE:%LB_TARGET_ARCH% pixman\release\*.obj /OUT:%NAME%_static.lib

echo EXPORTS >> %NAME%.def
link /DUMP /symbols /exports %NAME%_static.lib | grep " notype ()    External " | grep " SECT"  | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def

link /MACHINE:%LB_TARGET_ARCH% /OUT:%NAME%.dll /DEF:%NAME%.def /DLL /RELEASE /SWAPRUN:NET /SWAPRUN:CD %LB_OBJS% %NAME%_static.lib

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
endlocal
popd
