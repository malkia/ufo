@echo off
set LB_PROJECT_REPO=redis
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\deps\hiredis
git clean -fdx

rem git://github.com/MSOpenTech/redis.git
rem origin/bksavecow
rem patch -p1 < redis.diff

set NAME=%LB_PROJECT_NAME%
set FILES=async.c dict.c hiredis.c net.c sds.c ..\..\src\win32fixes.c

cl -c %LB_CL_OPTS% -Fe%NAME%.dll -LD -Dvsnprintf=_vsnprintf -D_create_locale=__get_current_locale -DWIN32=1 %FILES%

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=12
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=11

link /LIB /OUT:%NAME%_static.lib *.obj
echo EXPORTS > %NAME%.def
link /DUMP /NOLOGO /LINKERMEMBER:1 %NAME%_static.lib | grep -E " [ 0-9A-Z]{7}[0-9A-Z] [A-Za-z_]+" | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def
link /DEF:%NAME%.def /OUT:%NAME%.dll %LB_LINK_OPTS% %NAME%_static.lib ws2_32.lib wsock32.lib

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd

