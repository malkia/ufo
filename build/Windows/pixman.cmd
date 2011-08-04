@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
setlocal

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=12
if "%LB_TARGET_BITS%"=="32" set MMX=off
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=11
if "%LB_TARGET_BITS%"=="64" set MMX=off

git clean -fdx

for /F "tokens=1,2,3 delims=[](), " %%i in (configure.ac) do if "%%i"=="m4_define" (
    if "%%j"=="pixman_major" set VERSION_MAJOR=%%k
    if "%%j"=="pixman_minor" set VERSION_MINOR=%%k
    if "%%j"=="pixman_micro" set VERSION_MICRO=%%k
)

set NAME=%LB_PROJECT_NAME%

sed -e "s/@PIXMAN_VERSION_MAJOR@/%VERSION_MAJOR%/g"^
    -e "s/@PIXMAN_VERSION_MINOR@/%VERSION_MINOR%/g"^
    -e "s/@PIXMAN_VERSION_MICRO@/%VERSION_MICRO%/g"^
     < pixman/pixman-version.h.in^
     > pixman/pixman-version.h

make -k MMX=%MMX% CC="cl /arch:SSE2 /GL /O2 /Ob2 /Ox /Oi /Ot /Oy /GF /Zi /Fd%NAME%.pdb" -C pixman -f Makefile.win32 CFG=release
link /LIB /MACHINE:%LB_TARGET_ARCH% pixman\release\*.obj /OUT:%NAME%_static.lib

echo EXPORTS > %NAME%.def
link /DUMP /NOLOGO /linkermember %NAME%_static.lib | grep -E " [ 0-9A-Z]{7}[0-9A-Z] [A-Za-z_]+" | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def
link /LTCG /NOLOGO /MACHINE:%LB_TARGET_ARCH% /OUT:%NAME%.dll /PDB:%NAME%.pdb /DEF:%NAME%.def /DLL /RELEASE /SWAPRUN:NET /SWAPRUN:CD %LB_OBJS% %NAME%_static.lib

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install pixman\%NAME%.pdb
endlocal
popd
