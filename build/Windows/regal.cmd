@echo off
set LB_PROJECT_REPO=regal
call %~dp0/wdk/setup %~n0 %*
setlocal
pushd %LB_PROJECT_ROOT%
git clean -fdx

cd build\win32\vs2010\Regal
set NAME=%LB_PROJECT_NAME%

(for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile %NAME%.vcxproj`) do echo %%i) > sources.tmp
echo ..\..\..\..\src\md5\src\md5.c >> sources.tmp

cl %LB_CL_OPTS% -Fe%NAME%.dll^
   -D_MSC_VER=1399^
   -DWIN32=1^
   -DNDEBUG=1^
   -DREGAL_EMULATION=0^
   -DREGAL_EXPORTS=1^
   -DREGAL_SYS_WGL_DECLARE_WGL=1^
   -DREGAL_DECL_EXPORT=1^
   -DREGAL_LOG_ALL=0^
   -DREGAL_NO_TLS=1^
   -DREGAL_NO_HTTP=1^
   -DREGAL_NO_GETENV=1^
   -DREGAL_NO_ASSERT=1^
   -I..\..\..\..\src\boost^
   -I..\..\..\..\src\mongoose^
   -I..\..\..\..\src\md5\include^
   -I..\..\..\..\src\zlib\include^
   -I..\..\..\..\src\libpng\include^
   -I..\..\..\..\include -LD @sources.tmp^
   /link"%LB_LINK_OPTS% /DEF:..\..\..\..\src\regal\regal.def ws2_32.lib advapi32.lib gdi32.lib user32.lib %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\png.lib"

rem Use the Tls API on Windows
rem -DREGAL_WIN_TLS=1^

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
call %~dp0/wdk/install %LB_PROJECT_NAME%.pdb
endlocal
popd

