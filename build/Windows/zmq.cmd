@echo off
set LB_PROJECT_REPO=libzmq
call %~dp0/wdk/setup %~n0 %*
setlocal
pushd %LB_PROJECT_ROOT%
git clean -fdx

rem git checkout c3f7543ebe08cfdadf218fa558f03a5d382d322c

cd builds\msvc\libzmq
set NAME=%LB_PROJECT_NAME%

(for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile lib%NAME%.vcxproj`) do if /I NOT "%%~ni"=="device" echo %%i) > sources.tmp
rem echo "..\..\..\src\proxy.cpp" >> sources.tmp
rem echo "..\..\..\src\address.cpp" >> sources.tmp
rem echo "..\..\..\src\v1_encoder.cpp" >> sources.tmp
rem echo "..\..\..\src\v1_decoder.cpp" >> sources.tmp

cl %LB_CL_OPTS% -Dssize_t=SSIZE_T -EHsc -Fe%NAME%.dll -LD -DZMQ_HAVE_OPENPGM=1 -DFD_SETSIZE=1024 -DDLL_EXPORT=1 -DNDEBUG=1 -I.. -I..\..\src -I"%~dp0\include"^
 -I"%LB_PROJECT_ROOT%\..\openpgm\pgm\include" -DNOMINMAX @sources.tmp /link"%LB_LINK_OPTS% ws2_32.lib rpcrt4.lib %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\pgm.lib"

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
call %~dp0/wdk/install %LB_PROJECT_NAME%.pdb
endlocal
popd
