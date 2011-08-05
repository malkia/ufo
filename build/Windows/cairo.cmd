@echo off
call %~dp0/wdk/setup %~n0 %*
cl %LB_CL_OPTS% -c maglev.c
pushd %LB_PROJECT_ROOT%
setlocal

git clean -fdx

move %~dp0maglev.obj %LB_PROJECT_ROOT%\src
copy /y %~dpn0.features build\Makefile.win32.features
copy /y %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\pixman.lib %LB_PROJECT_ROOT%\..\pixman\pixman\release\pixman-1.lib
copy /y %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\zlib.lib   %LB_PROJECT_ROOT%\..\zlib\zdll.lib
copy /y %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\libpng.lib %LB_PROJECT_ROOT%\..\libpng\libpng.lib
mkdir %LB_PROJECT_ROOT%\src\GL
copy /y %~dp0GL\glext.h %LB_PROJECT_ROOT%\src\GL
make -f Makefile.win32 CFG=release CC="cl %LB_CL_OPTS%" AR="link /LIB" LD="link %LB_LINK_OPTS% opengl32.lib maglev.obj"

call %~dp0/wdk/install src\release\%LB_PROJECT_NAME%.dll
call %~dp0/wdk/install src\release\%LB_PROJECT_NAME%.lib
call %~dp0/wdk/install src\%LB_PROJECT_NAME%.pdb
endlocal
popd
