@echo off
set LB_PROJECT_REPO=bzip2
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
git clean -fdx
setlocal

set NAME=%LB_PROJECT_NAME%

nmake lib -f makefile.msc CC="cl %LB_CL_OPTS%" AR="link /LIB" LD="link %LB_LINK_OPTS%"
echo LIBRARY %NAME%>%NAME%.def
for /f "skip=2" %%i in (lib%NAME%.def) do echo %%i >> %NAME%.def
link /DEF:%NAME%.def /OUT:%NAME%.dll %LB_LINK_OPTS% lib%NAME%.lib

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd

