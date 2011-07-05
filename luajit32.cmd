@SET LUA_PATH=%~dp0\?.lua;%LUA_PATH%
@SET PATH=%~dp0;%PATH%
@"%~dp0bin\Windows\x86\luajit.exe" %*
