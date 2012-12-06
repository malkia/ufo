@echo off
setlocal
set LB_PROJECT_REPO=libtiff
call %~dp0/wdk/setup %~n0 %*
set NAME=%LB_PROJECT_NAME%
pushd %LB_PROJECT_ROOT%\lib%NAME%

echo.>tif_stream.c

del *.obj
nmake -f Makefile.vc^
      DLLNAME=%NAME%.dll^
      CC="cl -LD -I. %LB_CL_OPTS% -Dfstat=_fstat"^
      AR="link /LIB"^
      LD="link %LB_LINK_OPTS%"

call %~dp0/wdk/install    %NAME%.dll
call %~dp0/wdk/install lib%NAME%.lib %NAME%.lib
call %~dp0/wdk/install    %NAME%.pdb
endlocal
popd

