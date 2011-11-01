@echo off
call %~dp0/wdk/setup %~n0 %*
SetLocal EnableExtensions EnableDelayedExpansion
pushd %LB_PROJECT_ROOT%\src

git clean -fdx

for /F %%i in (%~dp0..\source\zmq.files) do set _FILES=!_FILES! %%i

cl %LB_CL_OPTS% -EHsc -Fe%LB_PROJECT_NAME%.dll -LD -DDLL_EXPORT=1 -DNDEBUG=1 -Iwin32 -I. -I..\builds\msvc -I"%~dp0\include" -DNOMINMAX -FI%~dpn0-missing.h^
   %_FILES% /link"%LB_LINK_OPTS% ws2_32.lib rpcrt4.lib"

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
call %~dp0/wdk/install %LB_PROJECT_NAME%.pdb
endlocal
popd
