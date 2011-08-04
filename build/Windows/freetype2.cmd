@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\src

git clean -fdx

set NAME=%LB_PROJECT_NAME%

cl -MD -Fe%NAME%.dll -MD -LD -DNDEBUG=1 -DWIN32 -DFT2_BUILD_LIBRARY -nologo -GL -O1 -Os -Oy -GF -GL -I%~dp0%NAME% -I..\include -arch:SSE2 -MP %LB_OBJS% @%~dp0..\source\%NAME%.files user32.lib opengl32.lib gdi32.lib winmm.lib /link"/LTCG /RELEASE /SWAPRUN:NET /SWAPRUN:CD"

rem call %~dp0/wdk/install glfw.dll
rem call %~dp0/wdk/install glfw.lib
popd
