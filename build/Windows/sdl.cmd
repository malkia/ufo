@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\VisualC\SDL
setlocal

call hg purge --all

set NAME=%LB_PROJECT_NAME%
rem don't forget to "hg checkout SDL-1.2"

copy ..\..\include\SDL_config_win32.h ..\..\include\SDL_config.h 1>nul 2>nul

del sources.tmp 1>nul 2>nul
(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr RelativePath %NAME%.vcproj`) do if /I "%%~xj"==".c" echo %%j) > sources.tmp

cl %LB_CL_OPTS% -LD -Fe%NAME%.dll -DNDEBUG=1 -D_WINDOWS -I"%DXSDK_DIR%\include" -I..\..\include -I"%~dp0include" @sources.tmp /link"%LB_LINK_OPTS% user32.lib gdi32.lib kernel32.lib winmm.lib imm32.lib ole32.lib version.lib oleaut32.lib dxguid.lib advapi32.lib"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb

endlocal
popd
goto :eof

