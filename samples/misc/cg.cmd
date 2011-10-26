@echo off
cd /d %~dp0
call ..\..\luajit32 cg.lua
