@echo off
set LB_PROJECT_REPO=libzmq
call %~dp0/wdk/setup %~n0 %*
setlocal
pushd %LB_PROJECT_ROOT%
git clean -fdx

cd builds\msvc\libzmq
set NAME=%LB_PROJECT_NAME%

(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr RelativePath lib%NAME%.vcproj`) do if /I "%%~xj"==".cpp" echo %%j) > sources.tmp

copy /y "%LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\pgm.lib" libpgm.lib"

cl %LB_CL_OPTS% -EHsc -Fe%NAME%.dll -LD -DZMQ_HAVE_OPENPGM=1 -DFD_SETSIZE=1024 -DDLL_EXPORT=1 -DNDEBUG=1 -I.. -I..\..\src -I"%~dp0\include" -I"%LB_PROJECT_ROOT%\..\openpgm\pgm\include" -DNOMINMAX @sources.tmp /link"%LB_LINK_OPTS% ws2_32.lib rpcrt4.lib"

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
call %~dp0/wdk/install %LB_PROJECT_NAME%.pdb
endlocal
popd
