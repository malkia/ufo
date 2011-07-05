@echo off
setlocal

set _ROOT=%~dp0..\..
set _SRC=%_ROOT%\..\libzmq\src
set _ARCH=%1
set _WDK=%2

if "%_ARCH%"==""   set _ARCH=32
if "%_WDK%"==""    set _WDK=e:\apps\wdk
if "%_ARCH%"=="32" set _TARGET=i386
if "%_ARCH%"=="32" set _LUA_ARCH=x86
if "%_ARCH%"=="64" set _TARGET=amd64
if "%_ARCH%"=="64" set _LUA_ARCH=x64
if "%_TARGET%"=="" (
    echo You should specify 32 or 64 as first argument 
    goto :EOF
)

set _CROSS_TARGET=
if "%_TARGET%"=="amd64" set _CROSS_TARGET=x32-64

echo Compiling ZeroMQ: [_ARCH=%_ARCH%] [_TARGET=%_TARGET%] [_CROSS_TARGET=%_CROSS_TARGET%]
call %_WDK%\bin\setenv.bat %_WDK% fre %_CROSS_TARGET% win7 no_oacr

set LIB=%BASEDIR%\lib\crt\%_TARGET%;%BASEDIR%\lib\win7\%_TARGET%;%LIB%
set INCLUDE=%CRT_INC_PATH%;%INCLUDE%;
set INCLUDE=%SDK_INC_PATH%\crt\stl60;%INCLUDE%;

pushd %_SRC%
del link.cmd cl.cmd *.obj buildvm_*.h 1>nul 2>nul
if "%_TARGET%"=="i386" (
   set _FILES=%_WDK%\lib\win7\%_TARGET%\msvcrt_win2000.obj
)
set _FILES=%_FILES% clock.cpp command.cpp connect_session.cpp ctx.cpp dealer.cpp decoder.cpp devpoll.cpp dist.cpp
set _FILES=%_FILES% encoder.cpp epoll.cpp err.cpp fq.cpp io_object.cpp io_thread.cpp ip.cpp kqueue.cpp lb.cpp
set _FILES=%_FILES% mailbox.cpp msg.cpp mtrie.cpp named_session.cpp object.cpp options.cpp own.cpp pair.cpp
set _FILES=%_FILES% pgm_receiver.cpp pgm_sender.cpp pgm_socket.cpp pipe.cpp poll.cpp poller_base.cpp pub.cpp
set _FILES=%_FILES% pull.cpp push.cpp random.cpp reaper.cpp rep.cpp req.cpp router.cpp select.cpp session.cpp
set _FILES=%_FILES% signaler.cpp socket_base.cpp sub.cpp tcp_connecter.cpp tcp_listener.cpp tcp_socket.cpp
set _FILES=%_FILES% thread.cpp transient_session.cpp trie.cpp uuid.cpp xpub.cpp xrep.cpp xreq.cpp xsub.cpp
set _FILES=%_FILES% zmq.cpp zmq_connecter.cpp zmq_engine.cpp zmq_init.cpp zmq_listener.cpp zmq_utils.cpp

set _OPTS=-O2 -Os -Oy -GF -GL -arch:SSE2 -MP
call cl -EHsc -MD -Fezmq.dll -LD -DDLL_EXPORT=1 -nologo %_OPTS% -Iwin32 -I. -I..\builds\msvc -I%~dp0 -DNOMINMAX  -FI%~dpn0-missing.h %_FILES% ws2_32.lib rpcrt4.lib
del config.h 1>nul 2>nul

del link.cmd cl.cmd 1>nul 2>nul
git log -1 >> zmq.dll
call :install zmq.dll %_ROOT%\bin\Windows\%_LUA_ARCH%
popd
goto :EOF

:install
echo install: [move /y %*]
move /y %*
goto :EOF
