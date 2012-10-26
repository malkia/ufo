@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\src
setlocal

git clean -fdx
rem git checkout 4baa01be78e5b9132ec94763126e01d82ab56626
git checkout master

echo @echo off > %~dp0/bin/cl.cmd
echo echo ....... Custom cl.cmd [%%*] >> %~dp0/bin/cl.cmd
echo set PDB= >> %~dp0/bin/cl.cmd
echo if exist buildvm.exe set PDB=/Fdluajit.pdb >> %~dp0/bin/cl.cmd
echo if exist luajit.dll set PDB=/Fdluajit.pdb >> %~dp0/bin/cl.cmd
echo cl.exe %LB_CL_OPTS% /D_MSC_VER=1399 /DLUAJIT_ENABLE_LUA52COMPAT=1 %%* %%PDB%% >> %~dp0/bin/cl.cmd

echo @echo off > %~dp0/bin/link.cmd
echo echo ....... Custom link.cmd [%%*] >> %~dp0/bin/link.cmd
echo set PDB= >> %~dp0/bin/link.cmd
echo if exist buildvm.exe set PDB=-PDB:luajit.pdb >> %~dp0/bin/link.cmd
echo if exist luajit.dll set PDB=-PDB:luajit.pdb >> %~dp0/bin/link.cmd
echo link.exe /DEBUG %LB_OBJS% %%* %%PDB%% >> %~dp0/bin/link.cmd
call msvcbuild amalg

call %~dp0/wdk/install luajit.dll
call %~dp0/wdk/install luajit.lib
call %~dp0/wdk/install luajit.pdb
call %~dp0/wdk/install luajit.exe

endlocal
popd
