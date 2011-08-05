@echo off
call %~dp0/wdk/setup %~n0 %*
SetLocal EnableExtensions EnableDelayedExpansion
pushd %LB_PROJECT_ROOT%\src
git clean -fdx

set NAME=%LB_PROJECT_NAME%

copy /y "%~dpn0-config.h" config.h
for /F %%i in (%~dp0..\source\%NAME%.files) do set FILES=!FILES! %%i
for /F %%i in (%~dp0..\source\%NAME%.Windows.files) do set FILES=!FILES! %%i

cl %LB_CL_OPTS% -Fe%NAME%.dll -LD -DGLFW_BUILD_DLL=1 -Iwin32 -I. %FILES%^
   /link"%LB_LINK_OPTS% user32.lib opengl32.lib gdi32.lib winmm.lib"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd

