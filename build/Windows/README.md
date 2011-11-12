This directory contains batch files to compile external libraries using the Windows DDK (WDK) 7.1

The goal is to link them with the system MSVCRT.DLL, instead of statically linking or linking them to the compiler specific MSVCRxx.DLL, such as MSVCR71, MSVCR80, MSVCR90, MSVCR100

Ideally the code should work back to Windows 2000, but realistically Windows XP SP3.

Some effort has been taking to introduce mini build system to simplify the batch files, but it's still not quite clear.

In the future, these scripts along with the OSX, Linux and other platforms would be rewritten in some existing, or new build system.

There is no need to incrementally compile a project. All projects are always compiled from fresh, for example after "git clean -fdx" is done on the root folder, and then patches applied.

This guarantees that there are no side effects from previous compilations, or generated files.

