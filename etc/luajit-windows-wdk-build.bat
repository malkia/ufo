@echo off

setlocal
set _LUAJITDIR=%~dp0..\..\luajit\src
set _OTHERDIR=%~dp0

set _VSDIR=
if NOT "%VS90COMNTOOLS%"=="" ( 
  set _VSDIR="%VS90COMNTOOLS%\..\..\"
) ELSE IF NOT "%VCINSTALLDIR%"=="" ( 
  set _VSDIR="%VCINSTALLDIR%\..\"
) ELSE IF NOT "%VSINSTALLDIR%"=="" ( 
  set _VSDIR="%VSINSTALLDIR%\"
) ELSE (
  echo At least one of the environment variables must be set:
  echo VS90COMNTOOLS, VCINSTALLDIR or VSINSTALLDIR
  goto :EOF
)

set ARCH=%1
if "%ARCH%"=="" set ARCH=i386
if "%ARCH%"=="32" set ARCH=i386
if "%ARCH%"=="64" set ARCH=amd64
set ARCH2=%ARCH%
if "%ARCH%"=="amd64" set ARCH2=x32-64

echo ARCH=%ARCH%
call d:\wdk\bin\setenv.bat d:\wdk fre %ARCH2% WIN7 no_oacr
set LIB=%BASEDIR%\lib\crt\%ARCH%;%BASEDIR%\lib\win7\%ARCH%;
set INCLUDE=%CRT_INC_PATH%;%INCLUDE%;

pushd
cd /d %_LUAJITDIR%
for %%j in (amalg static) do (
  call MSVCBUILD-mt.bat %%j
  for %%i in (exe dll exp lib) do ( 
    move /y lua51.%%i luajit.%%i
    if "%ARCH%"=="amd64" ( 
       move /y luajit.%%i luajit64.%%i
       echo copy luajit64.%%i %_OTHERDIR%
       copy luajit64.%%i %_OTHERDIR%
    ) ELSE (
       echo copy luajit.%%i %_OTHERDIR%
       copy luajit.%%i %_OTHERDIR%
    )
  )
)
popd
