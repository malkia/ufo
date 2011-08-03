@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
setlocal

git clean -fdx

copy /y %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\zlib.lib %LB_PROJECT_ROOT%\..\zlib
nmake -f scripts/makefile.vcwin32 CC="cl -I." AR="link /LIB"

set NAME=%LB_PROJECT_NAME%

move /y %NAME%.lib %NAME%_static.lib

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=50
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=49

echo EXPORTS >> %NAME%.def
link /DUMP /symbols /exports %NAME%_static.lib | grep " notype ()    External " | grep " SECT"  | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def
link /MACHINE:%LB_TARGET_ARCH% /OUT:%NAME%.dll /DEF:%NAME%.def /DLL /RELEASE /SWAPRUN:NET /SWAPRUN:CD %LB_OBJS% %NAME%_static.lib %LB_PROJECT_ROOT%\..\zlib\zlib.lib
move /y %NAME%.dll %LB_PROJECT_NAME%.dll

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
endlocal
popd

