@echo off
call %~dp0/wdk/setup %~n0 %*
setlocal
pushd %LB_PROJECT_ROOT%
git clean -fdx
call win32\generate.bat
pushd %LB_PROJECT_ROOT%\win32
set NAME=%LB_PROJECT_NAME%

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=12
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=11

echo.>sources.tmp
echo ..\apps\mudraw.c >> sources.tmp
echo ..\apps\mupdfclean.c >> sources.tmp
echo ..\apps\mupdfextract.c >> sources.tmp
echo ..\apps\mupdfinfo.c >> sources.tmp
echo ..\apps\mupdfposter.c >> sources.tmp
echo ..\apps\mupdfshow.c >> sources.tmp
echo ..\apps\pdfapp.c >> sources.tmp
echo ..\apps\win_main.c >> sources.tmp
(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr \thirdparty\jbig2dec libthirdparty.vcproj`) do if /I "%%~xj"==".c" echo %%j) >> sources.tmp
(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr \thirdparty\openjpeg libthirdparty.vcproj`) do if /I "%%~xj"==".c" echo %%j) >> sources.tmp
(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr \thirdparty\jpeg-9 libthirdparty.vcproj`) do if /I "%%~xj"==".c" echo %%j) >> sources.tmp
(for /f "usebackq tokens=1,2,3* delims==" %%i in (`findstr RelativePath lib%NAME%.vcproj`) do if /I "%%~xj"==".c" if /I NOT "%%~nj"=="memento" echo %%j) >> sources.tmp

rc ..\apps\win_res.rc
cl -c %LB_CL_OPTS% -Fe%NAME%.dll -LD -I..\fitz -I..\thirdparty\jbig2dec -Dvsnprintf=_vsnprintf^
   -DMUPDF_COMBINED_EXE=1 -I..\thirdparty\jpeg-9 -DOPJ_STATIC=1 -I..\scripts -I..\thirdparty\openjpeg-1.5.0\libopenjpeg^
    -I"%~dp0\include" -I"%LB_PROJECT_ROOT%\..\freetype2\include" -I"%LB_PROJECT_ROOT%\..\zlib" -I..\pdf -I..\cbz -I..\xps -I..\apps^
    @sources.tmp

rem Does not work yet (but would make it from 5MB -> 1MB)   -DNOCJK=1^

echo EXPORTS>%NAME%.def
link /LIB /OUT:%NAME%_static.lib *.obj
link /DUMP /LINKERMEMBER:1 %NAME%_static.lib | grep -E " [ 0-9A-Z]{7}[0-9A-Z] [A-Za-z_]+" | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def
link /DEF:%NAME%.def /OUT:%NAME%.dll %LB_LINK_OPTS% %NAME%_static.lib "%~dp0msvcrt_compat_%LB_TARGET_ARCH%.lib" %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\freetype2.lib %LB_ROOT%\bin\Windows\%LB_TARGET_ARCH%\z.lib^
     user32.lib kernel32.lib gdi32.lib advapi32.lib shell32.lib comdlg32.lib ..\apps\win_res.res

call %~dp0/wdk/install %LB_PROJECT_NAME%.dll
call %~dp0/wdk/install %LB_PROJECT_NAME%.lib
call %~dp0/wdk/install %LB_PROJECT_NAME%.pdb
endlocal
popd
popd
