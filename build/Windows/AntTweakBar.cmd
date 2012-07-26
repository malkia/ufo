@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\src
setlocal

set NAME=%LB_PROJECT_NAME%

mkdir release%LB_TARGET_BITS% 1>nul 2>nul
"%DXSDK_DIR%\Utilities\bin\x86\fxc" /T vs_4_0_level_9_1 /E LineRectVS /Fh         release%LB_TARGET_BITS%\TwDirect3D11_LineRectVS.h         TwDirect3D11.hlsl
"%DXSDK_DIR%\Utilities\bin\x86\fxc" /T vs_4_0_level_9_1 /E LineRectCstColorVS /Fh release%LB_TARGET_BITS%\TwDirect3D11_LineRectCstColorVS.h TwDirect3D11.hlsl
"%DXSDK_DIR%\Utilities\bin\x86\fxc" /T ps_4_0_level_9_1 /E LineRectPS /Fh         release%LB_TARGET_BITS%\TwDirect3D11_LineRectPS.h         TwDirect3D11.hlsl
"%DXSDK_DIR%\Utilities\bin\x86\fxc" /T vs_4_0_level_9_1 /E TextVS /Fh             release%LB_TARGET_BITS%\TwDirect3D11_TextVS.h             TwDirect3D11.hlsl
"%DXSDK_DIR%\Utilities\bin\x86\fxc" /T vs_4_0_level_9_1 /E TextCstColorVS /Fh     release%LB_TARGET_BITS%\TwDirect3D11_TextCstColorVS.h     TwDirect3D11.hlsl
"%DXSDK_DIR%\Utilities\bin\x86\fxc" /T ps_4_0_level_9_1 /E TextPS /Fh             release%LB_TARGET_BITS%\TwDirect3D11_TextPS.h             TwDirect3D11.hlsl

cl -LD -Fe%NAME%.dll %LB_CL_OPTS% -I"%DXSDK_DIR%/Include" -DTW_EXPORTS=1 -I../include^
   LoadOGL.cpp LoadOGLCore.cpp TwBar.cpp TwColors.cpp TwEventSFML.cpp TwFonts.cpp TwMgr.cpp^
   TwOpenGL.cpp TwOpenGLCore.cpp TwDirect3D9.cpp TwDirect3D10.cpp TwDirect3D11.cpp^
   TwEventSDL.c TwEventSDL12.c TwEventSDL13.c^
   /link"%LB_LINK_OPTS% user32.lib gdi32.lib kernel32.lib"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd
