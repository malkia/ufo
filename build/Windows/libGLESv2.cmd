@echo off
set LB_PROJECT_REPO=angleproject
call %~dp0/wdk/setup %~n0 %*
setlocal
pushd %LB_PROJECT_ROOT%

set NAME=%LB_PROJECT_NAME%
cd src\%NAME%

git clean -fdx

del *.obj 1>nul 2>nul

echo.>sources.tmp
rem echo.>sources_c.tmp

 for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile ..\compiler\translator_common.vcxproj`) do if /I "%%~xi"==".cpp" echo #include %%i > ..\compiler\translator_%%~nxi
(for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile ..\compiler\translator_common.vcxproj`) do if /I "%%~xi"==".cpp" echo ..\compiler\translator_%%~nxi) >> sources.tmp
(for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile ..\compiler\translator_hlsl.vcxproj`) do if /I "%%~xi"==".cpp" echo ..\compiler\\%%i) >> sources.tmp
 for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile ..\compiler\preprocessor\preprocessor.vcxproj`) do if /I "%%~xi"==".cpp" echo #include ^"preprocessor/%%~nxi^" > ..\compiler\preprocessor_%%~nxi
(for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile ..\compiler\preprocessor\preprocessor.vcxproj`) do if /I "%%~xi"==".cpp" echo ..\compiler\preprocessor_%%~nxi ) >> sources.tmp
(for /f "usebackq tokens=3 delims=>=/ " %%i in (`findstr ClCompile %NAME%.vcxproj`) do if /I "%%~xi"==".cpp" echo %%i) >> sources.tmp

set LB_CL_OPTS=%LB_CL_OPTS% -Dvsnprintf=_vsnprintf -DANGLE_DISABLE_TRACE=1 -DWIN32=1 -D_SECURE_SCL=0 -DLIBGLESV2_EXPORTS=1 -DNDEBUG=1 -DNOMINMAX  -I.. -I..\..\include -I"%~dp0include"  -I"%DXSDK_DIR%\include"

cl -LD -Fe%NAME%.dll %LB_CL_OPTS% -EHsc -FI"%~dpn0-missing.h" @sources.tmp^
 /link"%LB_LINK_OPTS% /DEF:%NAME%.def gdi32.lib user32.lib %DXSDK_DIR%/Lib/%LB_TARGET_ARCH%/dxguid.lib %DXSDK_DIR%/Lib/%LB_TARGET_ARCH%/d3d9.lib %DXSDK_DIR%/Lib/%LB_TARGET_ARCH%/d3dx9.lib %DXSDK_DIR%/Lib/%LB_TARGET_ARCH%/d3dcompiler.lib"

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
call %~dp0/wdk/install %LB_PROJECT_NAME%.pdb
endlocal
popd
