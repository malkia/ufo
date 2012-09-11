@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
fossil clean --force
set NAME=%LB_PROJECT_NAME%

sh -c "tclsh tools/genStubs.tcl generic generic/tcl.decls generic/tclInt.decls generic/tclTomMath.decls"
sh -c "tclsh tools/genStubs.tcl generic generic/tclOO.decls"
sh -c "tclsh tools/fix_tommath_h.tcl libtommath/tommath.h > generic/tclTomMath.h"

echo.>sources.tmp
for %%i in (regfronts.c regc_lex.c regc_color.c regc_nfa.c regc_cvec.c regc_locale.c rege_dfa.c tclUniData.c tclLoadNone.c) do echo.>>generic\%%i.exclude
for %%i in (libtommath\*.c) do if not exist %%i.exclude echo %%i >> sources.tmp
for %%i in (win\tclWin*.c) do if not exist %%i.exclude echo %%i >> sources.tmp
for %%i in (generic\*.c) do if not exist %%i.exclude echo %%i >> sources.tmp

echo -DCFG_RUNTIME_LIBDIR="""""">>sources.tmp
echo -DCFG_RUNTIME_BINDIR="""""">>sources.tmp
echo -DCFG_RUNTIME_SCRDIR="""""">>sources.tmp
echo -DCFG_RUNTIME_INCDIR="""""">>sources.tmp
echo -DCFG_RUNTIME_DOCDIR="""""">>sources.tmp
echo -DCFG_INSTALL_LIBDIR="""""">>sources.tmp
echo -DCFG_INSTALL_BINDIR="""""">>sources.tmp
echo -DCFG_INSTALL_SCRDIR="""""">>sources.tmp
echo -DCFG_INSTALL_INCDIR="""""">>sources.tmp
echo -DCFG_INSTALL_DOCDIR="""""">>sources.tmp
echo -DCFG_INSTALL_DOCDIR="""""">>sources.tmp
rem echo -DTCL_USE_STATIC_PACKAGES=1>>sources.tmp
echo -DTCL_CFGVAL_ENCODING="""cp1252""">>sources.tmp
echo -D"TCL_THREADS=1">>sources.tmp

cl -MD -Fd%LB_PROJECT_NAME%.pdb -Od -Z7 -MP -LD -Fe%NAME%.dll -DTCL_TOMMATH=1 -DMP_PREC=4 -DSTDC_HEADERS -DBUILD_tcl -DBUILD_tclOO -I win -I generic -I libtommath -I xlib -I bitmaps -Dinline=__inline -W0 @sources.tmp USER32.LIB GDI32.LIB NETAPI32.LIB "%~dp0msvcrt_compat_%LB_TARGET_ARCH%.lib" /link"%LB_LINK_OPTS%"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb

popd
