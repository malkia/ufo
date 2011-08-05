@echo off
set LB_LINK_SWAPRUN=-NOLOGO
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\src
setlocal

git clean -fdx

echo @echo off > cl.cmd
echo set PDB= >> cl.cmd
echo if exist buildvm.exe set PDB=/Fdlua51.pdb >> cl.cmd
echo if exist lua51.dll set PDB=/Fdluajit.pdb >> cl.cmd
echo cl.exe %LB_CL_OPTS% /D_MSC_VER=1399 /DLUAJIT_ENABLE_LUA52COMPAT=1 %%* %%PDB%% >> cl.cmd

rem LOL! /SWAPRUN:NET,CD makes Symantec AntiVir go crazy :)

echo @echo off > link.cmd
echo set PDB= >> link.cmd
echo if exist buildvm.exe set PDB=-PDB:lua51.pdb >> link.cmd
echo if exist lua51.dll set PDB=-PDB:luajit.pdb >> link.cmd
echo link.exe /DEBUG %LB_OBJS% %%* %%PDB%% >> link.cmd
call msvcbuild amalg

call %~dp0/wdk/install lua51.dll
call %~dp0/wdk/install lua51.lib
call %~dp0/wdk/install lua51.pdb
call %~dp0/wdk/install luajit.exe
call %~dp0/wdk/install luajit.pdb
endlocal
popd
