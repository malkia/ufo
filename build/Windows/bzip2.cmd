@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
setlocal

nmake -f makefile.msc CC="cl %LB_OBJS%" AR="link /LIB" LD="link /RELEASE /SWAPRUN:NET /SWAPRUN:CD %LB_OBJS%"

set NAME=%LB_PROJECT_NAME%

move /y zdll.lib %NAME%.lib

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
endlocal
popd

