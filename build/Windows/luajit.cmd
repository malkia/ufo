@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\src
setlocal

git clean -fdx

echo cl.exe /D_MSC_VER=1399 %%* > cl.cmd
rem LOL! /SWAPRUN:CD /SWAPRUN:NET makes Symantec AntiVir go crazy :)
echo link.exe /RELEASE %LB_OBJS% %%* > link.cmd
call msvcbuild amalg

call %~dp0/wdk/install lua51.dll
call %~dp0/wdk/install luajit.exe
endlocal
popd
