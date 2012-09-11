@echo off
set LB_PROJECT_REPO=angleproject
call %~dp0/wdk/setup %~n0 %*
setlocal
pushd %LB_PROJECT_ROOT%

set NAME=%LB_PROJECT_NAME%
cd src\%NAME%

(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr RelativePath %NAME%.vcproj`) do if /I "%%~xj"==".cpp" echo %%j) > sources.tmp

cl %LB_CL_OPTS% -EHsc -Fe%NAME%.dll -LD -DWIN32=1 -DLIBEGL_EXPORTS=1 -DNDEBUG=1 -DNOMINMAX -FI_70_new -I.. -I..\..\include -I"%~dp0include" -DNOMINMAX @sources.tmp /link"%LB_LINK_OPTS% gdi32.lib user32.lib opengl32.lib d3d9.lib dxguid.lib %~dp0/../../bin/%LB_TARGET_OS%/%LB_TARGET_ARCH%/libGLESv2.lib /DEF:%NAME%.def"

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
call %~dp0/wdk/install %LB_PROJECT_NAME%.pdb
endlocal
popd
