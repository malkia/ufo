@echo off
if "%LB_ROOT%"=="" goto :EOF
echo LB: INSTALL: [move /y %1 %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%]
for %%i in (dll exe) do if /I "%~x1"=="%%i" call :tagit %1
move /y %1 %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\%2
goto :EOF

:tagit
if exist "%LB_PROJECT_ROOT%\.git" git log -1 >> %1
if exist "%LB_PROJECR_ROOT%\.hg" sh -c "hg log -l 1" >> %1
goto :EOF

:error
echo %0 is part of the Windows DDK LB build system.
goto :EOF
