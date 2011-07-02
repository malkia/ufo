@echo off
setlocal
set LUA_PATH=%~dp0lib\luajit;%LUA_PATH%
@IF /I "%PROCESSOR_ARCHITECTURE%"=="AMD64" ("%~dpn064.cmd" %*) ELSE ("%~dpn032.cmd" %*)



