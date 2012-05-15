@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
git clean -fdx
setlocal

for /F "tokens=1,2,3 delims=[](), " %%i in (configure.ac) do if "%%i"=="m4_define" (
    if "%%j"=="glib_major_version" set MAJOR_VERSION=%%k
    if "%%j"=="glib_minor_version" set MINOR_VERSION=%%k
    if "%%j"=="glib_micro_version" set MICRO_VERSION=%%k
rem if "%%j"=="glib_binary_age" set BINARY_AGE=%%k
    if "%%j"=="glib_interface_age" set INTERFACE_AGE=%%k
)

set /A BINARY_AGE=100*%MINOR_VERSION% + %MICRO_VERSION%
echo GLIB VERSION %MAJOR_VERSION%.%MINOR_VERSION%.%MICRO_VERSION% (%BINARY_AGE%)

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

copy config.h.win32 config.h
copy glibconfig.h.win32 glibconfig.h

echo.>dummy.c
cl -c dummy.c
link /lib /out:dummy.lib dummy.obj
copy dummy.lib intl.lib
copy dummy.lib glib\pcre\pcre.lib
copy dummy.lib build\win32\dirent\dirent.lib

pushd build\win32\vs10
echo.>sources.tmp
(for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile gobject.vcxprojin`) do echo %%i) >> sources.tmp
(for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile gio.vcxprojin`) do echo %%i) >> sources.tmp
(for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile glib.vcxprojin`) do echo %%i) >> sources.tmp
rem (for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile gmodule.vcxproj`) do echo %%i) >> sources.tmp
cl %LB_CL_OPTS% -Fe%NAME%.dll -LD^
 -DGLIB_COMPILATION=1^
 -DDLL_EXPORT=1^
 -DNDEBUG=1^
 -I..\..\..^
 -I..\..\..\glib^
 -DLINK_SIZE=2^
 -DPCRE_STATIC=1^
 -DMAX_NAME_SIZE=32^
 -DMAX_NAME_COUNT=10000^
 -DNEWLINE=-1^
 -DPOSIX_MALLOC_THRESHOLD=10^
 -DMATCH_LIMIT=10000000^
 -DLIBDIR=""^
 -DMATCH_LIMIT_RECURSION=10000000^
 -DSUPPORT_UCP=1^
 -DSUPPORT_UTF=1^
 -DSUPPORT_UTF8=1^
 @sources.tmp^
 /link"%LB_LINK_OPTS% kernel32.lib"

rem call %~dp0/wdk/install %NAME%.dll
rem call %~dp0/wdk/install %NAME%.lib
rem call %~dp0/wdk/install %NAME%.pdb
endlocal
popd


