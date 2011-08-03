@echo off
call %~dp0/wdk/setup %~n0 %*
SetLocal EnableExtensions EnableDelayedExpansion
pushd %LB_PROJECT_ROOT%\src

git clean -fdx

for /F %%i in (%~dp0..\source\zmq.files) do set _FILES=!_FILES! %%i

cl -GL -EHsc -MD -Fe%LB_PROJECT_NAME%.dll -LD -DDLL_EXPORT=1 -nologo -O1 -Os -Oi -Ob2 -Oy -GF -GL -MP -DNDEBUG=1 -Iwin32 -I. -I..\builds\msvc -I%~dp0 -DNOMINMAX -FI%~dpn0-missing.h %LB_OBJS% %_FILES% /link"/LTCG /RELEASE /SWAPRUN:NET /SWAPRUN:CD ws2_32.lib rpcrt4.lib"

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
endlocal
popd
