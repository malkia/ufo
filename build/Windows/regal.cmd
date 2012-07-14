@echo off
set LB_PROJECT_REPO=regal
call %~dp0/wdk/setup %~n0 %*
setlocal
pushd %LB_PROJECT_ROOT%
git clean -fdx

cd win32\vs2010\Regal
set NAME=%LB_PROJECT_NAME%

(for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile %NAME%.vcxproj`) do echo %%i) > sources.tmp

cl %LB_CL_OPTS% -Fe%NAME%.dll^
   -DWIN32^
   -DNDEBUG^
   -DREGAL_EXPORTS^
   -DREGAL_SYS_WGL_DECLARE_WGL^
   -DREGAL_DECL_EXPORT^
   -DREGAL_LOG_ALL=0^
   -I..\..\..\src\boost -I..\..\..\include -LD @sources.tmp^
   /link"%LB_LINK_OPTS% /DEF:..\..\..\src\regal\regal.def"

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
call %~dp0/wdk/install %LB_PROJECT_NAME%.pdb
endlocal
popd
