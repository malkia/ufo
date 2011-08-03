@echo off
call %~dp0/wdk/setup %~n0 %*

SetLocal EnableExtensions EnableDelayedExpansion
pushd %LB_PROJECT_ROOT%\src

git clean -fdx

copy /y "%~dpn0-config.h" config.h
for /F %%i in (%~dp0..\source\glfw.files) do set FILES=!FILES! %%i
for /F %%i in (%~dp0..\source\glfw.Windows.files) do set FILES=!FILES! %%i

cl -MD -Feglfw.dll -LD -DGLFW_BUILD_DLL=1 -nologo -GL -O1 -Os -Oy -GF -GL -arch:SSE2 -MP -Iwin32 -I. %LB_OBJS% %FILES% user32.lib opengl32.lib gdi32.lib winmm.lib /link"/LTCG /RELEASE /SWAPRUN:NET /SWAPRUN:CD"

call %~dp0/wdk/install glfw.dll
call %~dp0/wdk/install glfw.lib
popd
