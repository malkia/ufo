@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\src
setlocal

set NAME=%LB_PROJECT_NAME%
set DO_NOT_COMPILE=^
    main\windows\SDL_windows_main.c^
    video\SDL_gamma.c^
    video\SDL_renderer_gl.c^
    video\SDL_renderer_sw.c^
    video\dummy\SDL_nullrender.c^
    audio\SDL_mixer_m68k.c^
    audio\SDL_mixer_MMX.c^
    audio\SDL_mixer_MMX_VC.c^
    thread\windows\win_ce_semaphore.c^
    video\SDL_alphamult.c^
    video\SDL_blendfillrect.c^
    video\SDL_blendline.c^
    video\SDL_blendpoint.c^
    video\SDL_blendrect.c^
    video\SDL_drawline.c^
    video\SDL_drawpoint.c^
    video\SDL_drawrect.c^
    video\SDL_renderer_gles.c^
    video\SDL_yuv_mmx.c^
    video\SDL_yuv_sw.c^
    stdlib\SDL_stdlib.c

copy ..\include\SDL_config_windows.h ..\include\SDL_config.h 1>nul 2>nul

del sources.tmp 1>nul 2>nul
for %%i in (*.c) do call :addsrc %%i
for /D %%i in (*) do for %%j in (%%i\*.c) do call :addsrc %%j
for /D %%i in (*) do if /I NOT "%%i"=="main" for %%j in (%%i\windows\*.c) do call :addsrc %%j
for %%i in (directsound disk dummy winmm xaudio2) do for %%j in (audio\%%i\*.c) do call :addsrc %%j
for %%i in (direct3d opengl software) do for %%j in (render\%%i\*.c) do call :addsrc %%j
for %%i in (dummy) do for %%j in (video\%%i\*.c) do call :addsrc %%j

cl %LB_CL_OPTS% -LD -Fe%NAME%.dll -DNDEBUG=1 -D_WINDOWS -I"%DXSDK_DIR%\include" -I..\include -I"%~dp0include" @sources.tmp /link"%LB_LINK_OPTS% user32.lib gdi32.lib kernel32.lib winmm.lib imm32.lib ole32.lib version.lib oleaut32.lib"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb

endlocal
popd
goto :eof

:addsrc
for %%k in (%DO_NOT_COMPILE%) do if /I "%%k"=="%1" goto :EOF
echo %1 >> sources.tmp
goto :eof
