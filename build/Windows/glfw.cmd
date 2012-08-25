@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%\src

git clean -fdx
echo #define _GLFW_WIN32_WGL>config.h
echo #define _GLFW_NO_DLOAD_GDI32 1>>config.h
echo #define _GLFW_NO_DLOAD_WINMM 1>>config.h
git log --format=format:"#define _GLFW_VERSION_FULL ""%%H""" -1>>config.h

set NAME=%LB_PROJECT_NAME%

set FILES=^
  error.c fullscreen.c gamma.c init.c input.c joystick.c opengl.c time.c^
  win32_dllmain.c win32_fullscreen.c win32_gamma.c win32_init.c win32_input.c^
  win32_joystick.c win32_opengl.c win32_time.c win32_window.c window.c win32_native.c

set OPENGL=%LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\regal.lib
rem set OPENGL=opengl32.lib

cl %LB_CL_OPTS% -Fe%NAME%.dll -LD^
   -D_GLFW_BUILD_DLL=1^
   -Dvsnprintf=_vsnprintf^
   %FILES%^
   /link"%LB_LINK_OPTS% user32.lib gdi32.lib winmm.lib %OPENGL%"

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd

