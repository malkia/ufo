@echo off
set LB_PROJECT_REPO=libuv
call %~dp0/wdk/setup %~n0 %*
setlocal
pushd %LB_PROJECT_ROOT%
git clean -fdx

set NAME=%LB_PROJECT_NAME%

echo src/fs-poll.c>sources.tmp
echo src/inet.c>>sources.tmp
echo src/uv-common.c>>sources.tmp
for %%i in (src\ares\*.c) do echo %%i >> sources.tmp
for %%i in (src\win\*.c) do echo %%i >> sources.tmp

cl %LB_CL_OPTS% -EHsc -Fe%NAME%.dll -LD^
 -DHAVE_CONFIG_H -D_WIN32_WINNT=0x0600 -DEIO_STACKSIZE=262144 -D_GNU_SOURCE -DWIN32 -DNDEBUG^
 -DBUILDING_UV_SHARED^
 -D_set_invalid_parameter_handler=if^
 -Iinclude -Iinclude/uv-private -Isrc -Isrc/ares/config_win32^
 -I"%~dp0\include" @sources.tmp /link"%LB_LINK_OPTS% ws2_32.lib advapi32.lib psapi.lib Iphlpapi.lib"

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
call %~dp0/wdk/install %LB_PROJECT_NAME%.pdb
endlocal
popd
