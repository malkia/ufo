@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
setlocal
git clean -fdx

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=12
if "%LB_TARGET_BITS%"=="32" set MMX=off
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=11
if "%LB_TARGET_BITS%"=="64" set MMX=off


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

make MMX=%MMX% CC="cl -DPIXMAN_NO_TLS=1 %LB_CL_ARCH_SSE2% /GL /O2 /Ob2 /Ox /Oi /Ot /Oy /GF /Zi /Fd../%NAME%.pdb /wd4005" -C pixman -f Makefile.win32 CFG=release
echo EXPORTS > %NAME%.def
link /DUMP /NOLOGO /LINKERMEMBER:1 %NAME%/release/%NAME%-1.lib | grep -E " [ 0-9A-Z]{7}[0-9A-Z] [A-Za-z_]+" | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def
link /LTCG /NOLOGO /MACHINE:%LB_TARGET_ARCH% /OUT:%NAME%.dll /PDB:%NAME%.pdb /PDBCOMPRESS /DEF:%NAME%.def /DLL /DEBUG /OPT:REF /OPT:ICF=1000 /SWAPRUN:NET,CD %LB_OBJS% %NAME%/release/%NAME%-1.lib

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd
