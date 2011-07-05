@SET LUA_PATH=%~dp0\?.lua;%LUA_PATH%
@SET PATH=%~dp0;%PATH%
@IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" ("%~dpn064.cmd" %*) ELSE ("%~dpn032.cmd" %*)



