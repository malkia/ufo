@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_ROOT%\src
setlocal

set NAME=%LB_PROJECT_NAME%

cl -Fe%NAME%.dll %NAME%.c -LD %LB_CL_OPTS% /link"%LB_LINK_OPTS%"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd
