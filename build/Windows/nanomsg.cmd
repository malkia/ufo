@echo off
call %~dp0/wdk/setup %~n0 %*
setlocal
pushd %LB_PROJECT_ROOT%\src
git clean -fdx
set NAME=%LB_PROJECT_NAME%

dir /b/s *.c > sources.tmp
cl %LB_CL_OPTS% -Fe%NAME%.dll -LD^
   -DSP_HAVE_WINDOWS=1^
   -DSP_EXPORTS=1^
   -DSP_USE_LITERAL_IFADDR=1^
   @sources.tmp -I"%~dp0\include" -FI"%~dpn0.h" /link"%LB_LINK_OPTS% ws2_32.lib mswsock.lib"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd
