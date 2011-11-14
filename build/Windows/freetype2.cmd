@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
git clean -fdx
cd builds\win32\visualc

set NAME=%LB_PROJECT_NAME%

(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr /B SOURCE= freetype.dsp`) do if /I "%%~xj"==".c" echo %%j) > sources.tmp
echo ..\..\..\src\bzip2\ftbzip2.c >> sources.tmp

cl -c %LB_CL_OPTS% -Fe%NAME%.dll -DNDEBUG=1 -DWIN32 -DFT2_BUILD_LIBRARY^
   -I%LB_ROOT%\..\bzip2\^
   -I%~dp0%NAME% -I..\..\..\include @sources.tmp

move %NAME%.lib %NAME%_static.lib

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=12
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=11

echo EXPORTS>%NAME%.def
link /LIB /OUT:%NAME%_static.lib *.obj
link /DUMP /LINKERMEMBER:1 %NAME%_static.lib | grep -E " [ 0-9A-Z]{7}[0-9A-Z] [A-Za-z_]+" | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def
link /DEF:%NAME%.def /OUT:%NAME%.dll %LB_LINK_OPTS% %NAME%_static.lib %~dp0\..\..\bin\Windows\%LB_TARGET_ARCH%\bz2.lib

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
popd
