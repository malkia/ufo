@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\VisualC\SDL
setlocal

rem SDL-1.3 :)
rem hg update 7fe4b2b78acc

set NAME=%LB_PROJECT_NAME%
copy ..\..\include\SDL_config_win32.h ..\..\include\SDL_config.h

(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr RelativePath %NAME%_VS2008.vcproj`) do if /I "%%~xj"==".c" if /I NOT "%%~nxj"=="SDL_stdlib.c" echo %%j) > sources.tmp

cl %LB_CL_OPTS% -Z7 -MP -LD -Fe%NAME%.dll -DNDEBUG=1 -D_WINDOWS -I"%DXSDK_DIR%\include" -I..\..\include -I"%~dp0include" @sources.tmp /link"%LB_LINK_OPTS% user32.lib gdi32.lib kernel32.lib winmm.lib imm32.lib ole32.lib version.lib oleaut32.lib Advapi32.lib dxguid.lib"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb

endlocal
popd
goto :eof

:addsrc
for %%k in (%SRCFILTER%) do if /I "%%k"=="%1" goto :EOF
echo %1 >> sources.tmp
goto :eof
