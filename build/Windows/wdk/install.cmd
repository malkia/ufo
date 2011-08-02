@echo off
if "%LB_ROOT%"=="" goto :EOF
echo LB: INSTALL [move /y %1 %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%]
if exist "%LB_PROJECT_ROOT%\.git" git log -1 >> %1
if exist "%LB_PROJECR_ROOT%\.hg" sh -c "hg log -l 1" >> %1
move /y %1 %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%
