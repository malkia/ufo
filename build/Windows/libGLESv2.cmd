@echo off
set LB_PROJECT_REPO=angleproject
call %~dp0/wdk/setup %~n0 %*
setlocal
pushd %LB_PROJECT_ROOT%

set NAME=%LB_PROJECT_NAME%
cd src\%NAME%

del *.obj 1>nul 2>nul

echo.>sources.tmp
echo.>sources_c.tmp

(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr RelativePath ..\compiler\translator_common.vcproj`) do if /I "%%~xj"==".cpp" echo ..\compiler\\%%j) >> sources.tmp
(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr RelativePath ..\compiler\translator_common.vcproj`) do if /I "%%~xj"==".c" echo ..\compiler\\%%j) >> sources_c.tmp
(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr RelativePath ..\compiler\translator_hlsl.vcproj`) do if /I "%%~xj"==".cpp" echo ..\compiler\\%%j) >> sources.tmp
(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr RelativePath ..\compiler\translator_hlsl.vcproj`) do if /I "%%~xj"==".c" echo ..\compiler\\%%j) >> sources_c.tmp
(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr RelativePath ..\compiler\preprocessor\new\preprocessor.vcproj`) do if /I "%%~xj"==".cpp" if /I NOT "%%~nj"=="ExpressionParser" echo #include ^"%%~nxj^") > ..\compiler\preprocessor\new\pp_all.cpp
echo ..\compiler\preprocessor\new\ExpressionParser.cpp >> sources.tmp
echo ..\compiler\preprocessor\new\pp_all.cpp >> sources.tmp
(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr RelativePath %NAME%.vcproj`) do if /I "%%~xj"==".cpp" echo %%j) >> sources.tmp

cl -Dvsnprintf=_vsnprintf -c %LB_CL_OPTS% -Z7 -MP -EHsc -Fe%NAME%.dll -LD -DWIN32=1 -I"%DXSDK_DIR%\include" -DLIBGLESV2_EXPORTS=1 -DNDEBUG=1 -DNOMINMAX -FI_70_new -FI"%~dpn0-missing.h" -I.. -I..\..\include -I"%~dp0include" -DNOMINMAX @sources.tmp /link"%LB_LINK_OPTS% gdi32.lib user32.lib opengl32.lib"

cl -Dvsnprintf=_vsnprintf -c %LB_CL_OPTS% -Z7 -MP -EHsc -Fe%NAME%.dll -LD -DWIN32=1 -I"%DXSDK_DIR%\include" -DLIBGLESV2_EXPORTS=1 -DNDEBUG=1 -DNOMINMAX -I.. -I..\..\include -I"%~dp0include" -DNOMINMAX @sources_c.tmp /link"%LB_LINK_OPTS% gdi32.lib user32.lib opengl32.lib"

cl %LB_CL_OPTS% -Fe%NAME%.dll -LD  *.obj /link"%LB_LINK_OPTS% /DEF:%NAME%.def gdi32.lib user32.lib opengl32.lib dxguid.lib d3d9.lib %DXSDK_DIR%/Lib/%LB_TARGET_ARCH%/d3dx9.lib %DXSDK_DIR%/Lib/%LB_TARGET_ARCH%/d3dcompiler.lib"

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
call %~dp0/wdk/install %LB_PROJECT_NAME%.pdb
endlocal
popd
