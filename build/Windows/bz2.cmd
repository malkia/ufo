@echo off
set LB_PROJECT_REPO=libbz2
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
git clean -fdx
setlocal

set NAME=%LB_PROJECT_NAME%

nmake lib -f makefile.msc CC="cl %LB_CL_OPTS%" AR="link /LIB" LD="link %LB_LINK_OPTS%"
link /DEF:lib%LB_PROJECT_NAME%.def /OUT:%NAME%.dll %LB_LINK_OPTS% lib%NAME%.lib
move /y %LB_PROJECT_NAME%.pdb %NAME%.pdb

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd

