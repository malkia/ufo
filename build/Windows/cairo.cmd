@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
setlocal

git clean -fdx

copy /y %~dpn0.features build\Makefile.win32.features
copy /y ..\pixman\pixman.%LB_TARGET_ARCH%.lib ..\pixman\pixman\release\pixman-1.lib
make -f Makefile.win32 CFG=release AR="link /LIB" LD="link /RELEASE /SWAPRUN:NET /SWAPRUN:CD %LB_OBJS%"

call %~dp0/wdk/install src\release\%LB_PROJECT_NAME%.dll
endlocal
popd

