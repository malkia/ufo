@echo off
set LB_PROJECT_REPO=openpgm
call %~dp0/wdk/setup %~n0 %*
setlocal
set NAME=%LB_PROJECT_NAME%
pushd %LB_PROJECT_ROOT%\pgm

perl galois_generator.pl > galois_tables.tmp.c
python version_generator.py > version.tmp.c

echo galois_tables.tmp.c > @sources.tmp
echo version.tmp.c >> @sources.tmp

del *.c89.c sources.tmp
dir /b *.c | findstr /v _unittest.c | findstr /v _perftest.c | findstr /v backtrace | findstr /v http | findstr /v log | findstr /v pgmMIB |findstr /v signal | findstr /v snmp > sources0.tmp

for /F "usebackq tokens=1" %%i in (sources0.tmp) do (
    if exist %%~ni.c.c89.patch (
       copy /y %%i %%~ni.c89.c 1>nul 2>nul
       patch --binary -i %%~ni.c.c89.patch %%~ni.c89.c 1>nul 2>nul
       echo %%~ni.c89.c >> sources.tmp
    ) ELSE (
        echo %%i >> sources.tmp
    )
)

cl -c %LB_CL_OPTS%^
   -DWIN32^
   -D_CRT_SECURE_NO_WARNINGS^
   -DHAVE_FTIME^
   -DHAVE_ISO_VARARGS^
   -DHAVE_RDTSC^
   -DHAVE_WSACMSGHDR^
   -DHAVE_DSO_VISIBILITY^
   -DUSE_BIND_INADDR_ANY^
   -DUSE_16BIT_CHECKSUM^
   -DUSE_TICKET_SPINLOCK^
   -DUSE_DUMB_RWSPINLOCK^
   -DUSE_GALOIS_MUL_LUT^
   -DGETTEXT_PACKAGE='"pgm"'^
   -I..^
   -Iinclude^
   -I"%~dp0include"^
   @sources.tmp

del %NAME%_static.lib
link /LIB /OUT:%NAME%_static.lib *.obj

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=12
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=11

echo EXPORTS > %NAME%.def
link /DUMP /NOLOGO /LINKERMEMBER:1 %NAME%_static.lib | grep -E " [ 0-9A-Z]{7}[0-9A-Z] [A-Za-z_]+" | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def
link /DEF:%NAME%.def /OUT:%NAME%.dll %LB_LINK_OPTS% %NAME%_static.lib ws2_32.lib rpcrt4.lib IPHLPAPI.lib Winmm.lib ADVAPI32.lib

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd
