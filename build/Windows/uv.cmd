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
for %%i in (src\win\*.c) do echo %%i >> sources.tmp

REM _set_invalid_parameter_handler is missing in MSVCRT.DLL, and since we are targeting it it's declared as if() doing nothing.

cl %LB_CL_OPTS% -Fe%NAME%.dll -LD^
 -D_WIN32_WINNT=0x0600 -D_GNU_SOURCE -DNDEBUG -DBUILDING_UV_SHARED^
 -D_set_invalid_parameter_handler=if^
 -Iinclude -Iinclude/uv-private^
 @sources.tmp /link"%LB_LINK_OPTS% ws2_32.lib advapi32.lib psapi.lib iphlpapi.lib"

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
call %~dp0/wdk/install %LB_PROJECT_NAME%.pdb
endlocal
popd
