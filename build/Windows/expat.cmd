@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\lib
setlocal

set NAME=%LB_PROJECT_NAME%

grep SOURCE expat.dsp | grep "\.c$" | tr "\\" "/" | sed "s#SOURCE=./##g" > tempfiles.txt

cl %LB_CL_OPTS% -LD -Fe%NAME%.dll -DWIN32=1 -DCOMPILED_FROM_DSP=1 -DEXPAT_EXPORTS=1 -DNDEBUG=1 @tempfiles.txt /link"%LB_LINK_OPTS% /DEF:libexpat.def"

rem  user32.lib kernel32.lib ws2_32.lib wsock32.lib advapi32.lib shell32.lib rpcrt4.lib"
 
call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd
