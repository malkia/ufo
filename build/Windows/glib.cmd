@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
setlocal

git clean -fdx

make -f Makefile.msc 

rem AR="link /LIB" LD="link /RELEASE /SWAPRUN:NET /SWAPRUN:CD %LB_OBJS%"

endlocal
popd

