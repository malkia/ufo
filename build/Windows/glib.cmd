@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
git clean -fdx
setlocal

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=12
if "%LB_TARGET_BITS%"=="32" set MMX=off
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=11
if "%LB_TARGET_BITS%"=="64" set MMX=off

for /F "tokens=1,2,3 delims=[](), " %%i in (configure.ac) do if "%%i"=="m4_define" (
    if "%%j"=="glib_major_version" set MAJOR_VERSION=%%k
    if "%%j"=="glib_minor_version" set MINOR_VERSION=%%k
    if "%%j"=="glib_micro_version" set MICRO_VERSION=%%k
rem if "%%j"=="glib_binary_age" set BINARY_AGE=%%k
    if "%%j"=="glib_interface_age" set INTERFACE_AGE=%%k
)

set /A BINARY_AGE=100*%MINOR_VERSION% + %MICRO_VERSION%
echo GLIB VERSION %MAJOR_VERSION%.%MINOR_VERSION%.%MICRO_VERSION% (%BINARY_AGE%)
rem goto :EOF

set NAME=%LB_PROJECT_NAME%

copy /y glib\glibconfig.h.win32.in glibconfig.h.win32.in

for %%i in (glibconfig.h.win32.in glib/glibconfig.h.win32.in glib/glib.rc.in glib/makefile.msc.in config.h.win32.in) do (
    sed -e "s/@GLIB_MAJOR_VERSION@/%MAJOR_VERSION%/g"^
        -e "s/@GLIB_MINOR_VERSION@/%MINOR_VERSION%/g"^
        -e "s/@GLIB_MICRO_VERSION@/%MICRO_VERSION%/g"^
        -e "s/@GLIB_BINARY_AGE@/%BINARY_AGE%/g"^
        -e "s/@GLIB_INTERFACE_AGE@/%INTERFACE_AGE%/g"^
	-e "s/@GLIB_WIN32_STATIC_COMPILATION_DEFINE@//g"^
	-e "s/#define ENABLE_NLS 1//g"^
        < %%i^
        > %%~dpni
)

echo.>dummy.c
cl -c dummy.c
link /lib /out:dummy.lib dummy.obj
copy dummy.lib intl.lib
copy dummy.lib glib\pcre\pcre.lib
copy dummy.lib build\win32\dirent\dirent.lib

nmake -f Makefile.msc INTL=".."

rem make MMX=%MMX% CC="cl -DPIXMAN_NO_TLS=1 %LB_CL_OPTS%" -f Makefile.win32 CFG=release
rem echo EXPORTS > %NAME%.def
rem link /DUMP /NOLOGO /LINKERMEMBER:1 release/%NAME%-1.lib | grep -E " [ 0-9A-Z]{7}[0-9A-Z] [A-Za-z_]+" | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def
rem link /DEF:%NAME%.def /OUT:%NAME%.dll %LB_LINK_OPTS% release/%NAME%-1.lib

rem call %~dp0/wdk/install %NAME%.dll
rem call %~dp0/wdk/install %NAME%.lib
rem call %~dp0/wdk/install %NAME%.pdb
endlocal
popd


