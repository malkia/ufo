@echo off
if "%LB_ROOT%"=="" goto :EOF
echo LB: INSTALL: [move /y %1 %LB_ROOT%\bin\%LB_TARGET_OS%\%LB_TARGET_ARCH%]
for %%i in (dll exe) do if /I "%~x1"=="%%i" call :tagit %1
if /I "%~x1"==".pdb" (goto :move %1) ELSE (goto :move %1)
goto :EOF

:tagit
if exist "%LB_PROJECT_ROOT%\.git" git log -1 >> %1
if exist "%LB_PROJECR_ROOT%\.hg" sh -c "hg log -l 1" >> %1
goto :EOF

:pdb
setlocal
rem set PATH=%NTMAKEENV%\x86\%_BUILDARCH%;%PATH%
dir %1
del %LB_ROOT%\bin\%LB_TARGET_OS%\%LB_TARGET_ARCH%\%1
echo %~dp0..\pdbcopy %1 %LB_ROOT%\bin\%LB_TARGET_OS%\%LB_TARGET_ARCH%\%1 -p -vc6
dir %LB_ROOT%\bin\%LB_TARGET_OS%\%LB_TARGET_ARCH%\%1
endlocal
goto :EOF

:move
move /y %1 %LB_ROOT%\bin\%LB_TARGET_OS%\%LB_TARGET_ARCH%\%2
goto :EOF

:error
echo %0 is part of the %LB_TARGET_OS% DDK LB build system.
goto :EOF
