@echo off
set LB_PROJECT_REPO=postgresql
call %~dp0/wdk/setup %~n0 %*
setlocal

set NAME=%LB_PROJECT_NAME%
pushd %LB_PROJECT_ROOT%\src\interfaces\lib%NAME%
git clean -fdx

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=12
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=11

echo.>sources.tmp

set CPP=^
 ..\..\port\getaddrinfo.c^
 ..\..\port\pgstrcasecmp.c^
 ..\..\port\thread.c^
 ..\..\port\inet_aton.c^
 ..\..\port\crypt.c^
 ..\..\port\noblock.c^
 ..\..\port\chklocale.c^
 ..\..\port\inet_net_ntop.c^
 ..\..\backend\libpq\md5.c^
 ..\..\backend\libpq\ip.c^
 ..\..\backend\utils\mb\wchar.c^
 ..\..\backend\utils\mb\encnames.c^
 ..\..\port\snprintf.c^
 ..\..\port\strlcpy.c^
 ..\..\port\dirent.c^
 ..\..\port\dirmod.c^
 ..\..\port\pgsleep.c^
 ..\..\port\open.c^
 ..\..\port\win32error.c^
 ..\..\port\win32setlocale.c

echo EXPORTS > %NAME%.def
for /f "skip=2" %%i in (exports.txt) do echo %%i >> %NAME%.def
for %%i in (%CPP%) do echo %%i >> sources.tmp
for %%i in (*.c) do echo %%i >> sources.tmp

copy /y ..\..\include\pg_config.h.win32     ..\..\include\pg_config.h
copy /y ..\..\include\pg_config_ext.h.win32 ..\..\include\pg_config_ext.h
copy /y ..\..\include\port\win32.h ..\..\include\pg_config_os.h
copy /y ..\..\port\pthread-win32.h pthread-win32.h
echo.>pg_config_paths.h
for %%i in (SYSCONFDIR PGSHAREDIR INCLUDEDIR PKGINCLUDEDIR INCLUDEDIRSERVER LOCALEDIR HTMLDIR MANDIR LIBDIR PGBINDIR PKGLIBDIR DOCDIR) do echo #define %%i "" >> pg_config_paths.h
copy /y pg_config_paths.h ..\..\port\pg_config_paths.h

cl -LD -D"stat(x,y)=_stat(x,y)" %LB_CL_OPTS% -DWIN32=1 -DNDEBUG=1 -D"PG_TEXTDOMAIN(x)=x" -DFRONTEND=1 -DPG_MAJORVERSION="9.2" -D_WINDOWS=1 -Fe%NAME%.dll -I..\..\include -I..\..\include\port\win32  -I..\..\include\port\win32_msvc  -I..\..\include\port @sources.tmp /link"%LB_LINK_OPTS% /DEF:%NAME%.def kernel32.lib user32.lib advapi32.lib shfolder.lib wsock32.lib ws2_32.lib secur32.lib"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd
