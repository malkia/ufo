@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
setlocal

git clean -fdx

set DEBUG_RELEASE=release

copy /y %~dpn0.features build\Makefile.win32.features
mkdir %LB_PROJECT_ROOT%\..\pixman\pixman\%DEBUG_RELEASE%
copy /y %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\pixman.lib %LB_PROJECT_ROOT%\..\pixman\pixman\%DEBUG_RELEASE%\pixman-1.lib
copy /y %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\zlib.lib   %LB_PROJECT_ROOT%\..\zlib\zdll.lib
copy /y %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\png.lib    %LB_PROJECT_ROOT%\..\libpng\libpng.lib
mkdir %LB_PROJECT_ROOT%\src\GL
copy /y %~dp0..\include\GL\glext.h %LB_PROJECT_ROOT%\src\GL
copy %~dp0maglev.c %LB_PROJECT_ROOT%\src
pushd src && cl %LB_CL_OPTS% -c maglev.c && popd
make -f Makefile.win32 CFG=%DEBUG_RELEASE% CC="cl %LB_CL_OPTS%" AR="link /LIB" LD="link %LB_LINK_OPTS% opengl32.lib maglev.obj"

call %~dp0/wdk/install src\%DEBUG_RELEASE%\%LB_PROJECT_NAME%.dll
call %~dp0/wdk/install src\%DEBUG_RELEASE%\%LB_PROJECT_NAME%.lib
call %~dp0/wdk/install src\%LB_PROJECT_NAME%.pdb
endlocal
popd
