@echo off
call %~dp0/wdk/setup %~n0 %*
echo EXPORTS                    >  msvcrt_compat.def
echo _getpid=msvcrt._getpid     >> msvcrt_compat.def
echo _environ=msvcrt._environ   >> msvcrt_compat.def
echo _wenviron=msvcrt._wenviron >> msvcrt_compat.def
link /LIB /NODEFAULTLIB /DEF:msvcrt_compat.def /MACHINE:X86   /NAME:msvcrt.dll /OUT:msvcrt_compat_x86.lib
link /LIB /NODEFAULTLIB /DEF:msvcrt_compat.def /MACHINE:AMD64 /NAME:msvcrt.dll /OUT:msvcrt_compat_x64.lib
