@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\%LB_PROJECT_NAME%
git clean -fdx
setlocal

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=12
if "%LB_TARGET_BITS%"=="32" set MMX=off
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=11
if "%LB_TARGET_BITS%"=="64" set MMX=off

for /F "tokens=1,2,3 delims=[](), " %%i in (../configure.ac) do if "%%i"=="m4_define" (
    if "%%j"=="pixman_major" set VERSION_MAJOR=%%k
    if "%%j"=="pixman_minor" set VERSION_MINOR=%%k
    if "%%j"=="pixman_micro" set VERSION_MICRO=%%k
)

set NAME=%LB_PROJECT_NAME%

sed -e "s/@PIXMAN_VERSION_MAJOR@/%VERSION_MAJOR%/g"^
    -e "s/@PIXMAN_VERSION_MINOR@/%VERSION_MINOR%/g"^
    -e "s/@PIXMAN_VERSION_MICRO@/%VERSION_MICRO%/g"^
     < pixman-version.h.in^
     > pixman-version.h

make MMX=%MMX% CC="cl -DPIXMAN_NO_TLS=1 %LB_CL_OPTS%" -f Makefile.win32 CFG=release
echo EXPORTS > %NAME%.def
link /DUMP /NOLOGO /LINKERMEMBER:1 release/%NAME%-1.lib | grep -E " [ 0-9A-Z]{7}[0-9A-Z] [A-Za-z_]+" | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def
link /DEF:%NAME%.def /OUT:%NAME%.dll %LB_LINK_OPTS% release/%NAME%-1.lib

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd
