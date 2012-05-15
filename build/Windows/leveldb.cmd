@echo off
call %~dp0/wdk/setup %~n0 %*
pushd %LB_PROJECT_ROOT%
git clean -fdx

set NAME=%LB_PROJECT_NAME%
set FILES=async.c dict.c hiredis.c net.c sds.c ..\..\src\win32fixes.c

set FILES=db\builder.cc db\c.cc db\dbformat.cc db\db_bench.cc db\db_impl.cc db\db_iter.cc db\filename.cc db\log_reader.cc^
          db\log_writer.cc db\memtable.cc db\repair.cc db\table_cache.cc db\version_edit.cc db\version_set.cc db\write_batch.cc^
	  helpers\memenv\memenv.cc^
	  table\block.cc table\block_builder.cc table\filter_block.cc table\format.cc table\iterator.cc table\merger.cc table\table.cc^
	  table\table_builder.cc table\two_level_iterator.cc^
	  util\arena.cc util\bloom.cc util\cache.cc util\coding.cc util\comparator.cc util\crc32c.cc^
	  util\env.cc util\env_posix.cc util\filter_policy.cc util\hash.cc util\histogram.cc util\logging.cc^
	  util\options.cc util\status.cc util\testharness.cc util\testutil.cc^
	  port\port_posix.cc

cl -c -DOS_WIN=1 -I. -Iinclude -Iport/win -I"%~dp0include" -I%LB_PROJECT_ROOT%/../pthread -DLITTLE_ENDIAN=1 -Dsnprintf=_snprintf -EHsc -DLEVELDB_PLATFORM_POSIX=1 -DCOMPILER_MSVC=1 %LB_CL_OPTS% -Fe%NAME%.dll -LD %FILES%

if "%LB_TARGET_BITS%"=="32" set CUTSYMPOS=12
if "%LB_TARGET_BITS%"=="64" set CUTSYMPOS=11

link /LIB /OUT:%NAME%_static.lib *.obj
echo EXPORTS > %NAME%.def
link /DUMP /NOLOGO /LINKERMEMBER:1 %NAME%_static.lib | grep -E " [ 0-9A-Z]{7}[0-9A-Z] [A-Za-z_]+" | cut -b%CUTSYMPOS%- | sort | uniq >> %NAME%.def
link /DEF:%NAME%.def /OUT:%NAME%.dll %LB_LINK_OPTS% %NAME%_static.lib ws2_32.lib wsock32.lib

call %~dp0/wdk/install %NAME%.dll
call %~dp0/wdk/install %NAME%.lib
call %~dp0/wdk/install %NAME%.pdb
endlocal
popd

