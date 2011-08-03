@echo off
call %~dp0/wdk/setup %~n0 %*

setlocal
pushd %LB_ROOT%\src

if "%LB_PROJECT_ARCH%"=="x86" set OPTS=-arch:SSE2
set OPTS=%OPTS% -O2 -Os -Oy -GF -GL -MP

cl -MD -Feufo.dll -LD -nologo %_OPTS% %LB_OBJS% ufo.c /link"/LTCG /RELEASE /SWAPRUN:NET /SWAPRUN:CD"

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib

popd
endlocal
