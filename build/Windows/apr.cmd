@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
setlocal

rem svn co http://svn.apache.org/repos/asf/apr/apr/trunk/ apr
rem patch -p0 < apr.diff

set NAME=%LB_PROJECT_NAME%

(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr /B SOURCE= libapr.dsp`) do if /I "%%~xj"==".c" if /I NOT "%%~nj"=="apr_app" echo %%j) > sources.tmp

sed "s/type __stdcall/type/g" < include\apr.hw > include\apr.h
copy include\apu_want.hw include\apu_want.h
copy include\private\apu_select_dbm.hw include\private\apu_select_dbm.h

cl %LB_CL_OPTS% -LD -Fe%NAME%.dll -D_DLL -DAPR_DECLARE_EXPORT=1 -I"%~dp0include" -Iinclude -Iinclude/private -Iinclude/arch/win32 -Iinclude/arch/unix -I../expat/lib @sources.tmp /link"%LB_LINK_OPTS% user32.lib kernel32.lib ws2_32.lib wsock32.lib advapi32.lib shell32.lib rpcrt4.lib %~dp0/../../bin/%LB_TARGET_OS%/%LB_TARGET_ARCH%/expat.lib %~dp0msvcrt_compat_%LB_TARGET_ARCH%.lib oldnames.lib"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd
