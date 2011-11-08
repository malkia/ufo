@echo off
call %~dp0/wdk/setup libbz2 %*
pushd %LB_PROJECT_ROOT%
git clean -fdx
setlocal

set NAME=bz2

nmake lib -f makefile.msc CC="cl %LB_CL_OPTS%" AR="link /LIB" LD="link %LB_LINK_OPTS%"
move /y %LB_PROJECT_NAME%.lib %NAME%_static.lib
link /DEF:%LB_PROJECT_NAME%.def /OUT:%NAME%.dll %LB_LINK_OPTS% %NAME%_static.lib
move /y %LB_PROJECT_NAME%.pdb %NAME%.pdb

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd

