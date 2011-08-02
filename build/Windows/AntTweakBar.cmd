@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\src
echo %LB_PROJECT_ROOT%

mkdir release%LB_TARGET_BITS% 1>nul 2>nul
"%DXSDK_DIR%\Utilities\bin\x86\fxc" /T vs_4_0_level_9_1 /E LineRectVS /Fh         release%LB_TARGET_BITS%\TwDirect3D11_LineRectVS.h         TwDirect3D11.hlsl
"%DXSDK_DIR%\Utilities\bin\x86\fxc" /T vs_4_0_level_9_1 /E LineRectCstColorVS /Fh release%LB_TARGET_BITS%\TwDirect3D11_LineRectCstColorVS.h TwDirect3D11.hlsl
"%DXSDK_DIR%\Utilities\bin\x86\fxc" /T ps_4_0_level_9_1 /E LineRectPS /Fh         release%LB_TARGET_BITS%\TwDirect3D11_LineRectPS.h         TwDirect3D11.hlsl
"%DXSDK_DIR%\Utilities\bin\x86\fxc" /T vs_4_0_level_9_1 /E TextVS /Fh             release%LB_TARGET_BITS%\TwDirect3D11_TextVS.h             TwDirect3D11.hlsl
"%DXSDK_DIR%\Utilities\bin\x86\fxc" /T vs_4_0_level_9_1 /E TextCstColorVS /Fh     release%LB_TARGET_BITS%\TwDirect3D11_TextCstColorVS.h     TwDirect3D11.hlsl
"%DXSDK_DIR%\Utilities\bin\x86\fxc" /T ps_4_0_level_9_1 /E TextPS /Fh             release%LB_TARGET_BITS%\TwDirect3D11_TextPS.h             TwDirect3D11.hlsl

cl -GL -MD -FeAntTweakBar.dll -I%DXSDK_DIR%/Include -LD -nologo -O1 -Os -Oy -GF -GL -arch:SSE2 -MP -DTW_EXPORTS=1 -I../include %LB_OBJS% LoadOGL.cpp LoadOGLCore.cpp TwBar.cpp TwColors.cpp TwEventSFML.cpp TwFonts.cpp TwMgr.cpp TwOpenGL.cpp TwDirect3D9.cpp TwDirect3D10.cpp TwDirect3D11.cpp user32.lib gdi32.lib kernel32.lib /link"/LTCG /RELEASE /SWAPRUN:NET /SWAPRUN:CD"

call %~dp0/wdk/install AntTweakBar.dll
popd
