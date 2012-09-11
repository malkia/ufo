@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
fossil clean --force
set NAME=%LB_PROJECT_NAME%

echo.>sources.tmp
echo unix\tkUnixMenubu.c >>sources.tmp
echo unix\tkUnixScale.c >>sources.tmp
for %%i in (tkOldTest.c tkTest.c tkSquare.c tkStubLib.c) do echo.>>generic\%%i.exclude
for %%i in (generic\*.c) do if not exist %%i.exclude echo %%i >> sources.tmp
for %%i in (ttkStubLib.c) do echo.>>generic\ttk\%%i.exclude
for %%i in (generic\ttk\*.c) do if not exist %%i.exclude echo %%i >> sources.tmp
for %%i in (tkWinTest.c) do echo.>>win\%%i.exclude
for %%i in (win\*.c) do if not exist %%i.exclude echo %%i >> sources.tmp
for %%i in (xlib\*.c) do echo %%i >> sources.tmp

cl -MD -Fd%LB_PROJECT_NAME%.pdb -Od -Z7 -MP -Fe%NAME%.dll -DBUILD_tk -I win -I generic -I xlib -I bitmaps -I ..\tcl\generic -I ..\tcl\win -Dinline=__inline -W0 @sources.tmp USER32.LIB GDI32.LIB %LB_ROOT%/bin/Windows/%LB_TARGET_ARCH%/tcl.lib  /link"%LB_LINK_OPTS%"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb

popd
