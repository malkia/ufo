@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
fossil clean --force
set NAME=%LB_PROJECT_NAME%

echo.>sources.tmp
for %%i in (generic\*.c) do echo %%i >> sources.tmp
for %%i in (generic\ttk\*.c) do echo %%i >> sources.tmp
for %%i in (win\*.c) do echo %%i >> sources.tmp
for %%i in (xlib\*.c) do echo %%i >> sources.tmp

cl %LB_CL_OPTS% -Fe%NAME%.dll -I win -I generic -I xlib -I bitmaps -I ..\tcl\generic -Dinline=__inline -W0 @sources.tmp USER32.LIB GDI32.LIB

rem (for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr /B SOURCE= freetype.dsp`) do if /I "%%~xj"==".c" echo %%j) > sources.tmp
rem echo ..\..\..\src\bzip2\ftbzip2.c >> sources.tmp

rem cl -c %LB_CL_OPTS% -Fe%NAME%.dll -DNDEBUG=1 -DWIN32 -DFT2_BUILD_LIBRARY^
rem    -I%LB_ROOT%\..\bzip2\^
rem    -I%~dp0%NAME% -I..\..\..\include @sources.tmp

rem move %NAME%.lib %NAME%_static.lib

rem if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=12
rem if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=11

rem echo EXPORTS>%NAME%.def
rem link /LIB /OUT:%NAME%_static.lib *.obj
rem link /DUMP /LINKERMEMBER:1 %NAME%_static.lib | grep -E " [ 0-9A-Z]{7}[0-9A-Z] [A-Za-z_]+" | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def
rem link /DEF:%NAME%.def /OUT:%NAME%.dll %LB_LINK_OPTS% %NAME%_static.lib %~dp0\..\..\bin\Windows\%LB_TARGET_ARCH%\bz2.lib

rem call %~dp0/wdk/install %NAME%.dll
rem call %~dp0/wdk/install %NAME%.lib
rem call %~dp0/wdk/install %NAME%.pdb

popd
