@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
setlocal

set NAME=%LB_PROJECT_NAME%

grep SOURCE libapr.dsp | grep \.c$ | tr \\ "/" | sed "s#SOURCE=./##g" | sed "s#misc/win32/apr_app.c##g" > tempfiles.txt
copy include\apr.hw include\apr.h
copy include\apu_want.hw include\apu_want.h
copy include\private\apu_select_dbm.hw include\private\apu_select_dbm.h

cl %LB_CL_OPTS% -LD -Fe%NAME%.dll -D_DLL -DAPR_DECLARE_EXPORT=1 -I"%~dp0include" -Iinclude -Iinclude/private -Iinclude/arch/win32 -Iinclude/arch/unix -I../expat/lib @tempfiles.txt /link"%LB_LINK_OPTS% user32.lib kernel32.lib ws2_32.lib wsock32.lib advapi32.lib shell32.lib rpcrt4.lib %~dp0/../../bin/%LB_TARGET_OS%/%LB_TARGET_ARCH%/expat.lib oldnames.lib"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd
