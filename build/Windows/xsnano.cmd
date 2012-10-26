@echo off
call %~dp0/wdk/setup %~n0 %*
setlocal
pushd %LB_PROJECT_ROOT%\src
git clean -fdx
set NAME=%LB_PROJECT_NAME%

dir /b *.c > sources.tmp
cl %LB_CL_OPTS% -Dssize_t=SSIZE_T -Fe%NAME%.dll -LD -DXS_HAVE_WINDOWS=1 -DDLL_EXPORT=1 @sources.tmp -I../include -I"%~dp0\include" -I%~dp0../../../pthread /link"%LB_LINK_OPTS% ws2_32.lib"

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
call %~dp0/wdk/install %LB_PROJECT_NAME%.pdb
endlocal
popd
