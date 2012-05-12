local ffi  = require( "ffi" )
local libs = ffi_hiredis_libs or {
   OSX     = { x86 = "bin/OSX/hiredis.dylib",       x64 = "bin/OSX/hiredis.dylib" },
   Windows = { x86 = "bin/Windows/x86/hiredis.dll", x64 = "bin/Windows/x64/hiredis.dll" },
   Linux   = { x86 = "bin/Linux/x86/hiredis.so",    x64 = "bin/Linux/x86/hiredis.so", arm = "bin/Linux/arm/hiredis.so" },
   BSD     = { },
   POSIX   = { },
   Other   = { },
}
local lib  = ffi_hiredis_lib or libs[ ffi.os ][ ffi.arch ] or "hiredis"
local hiredis = ffi.load( lib )

ffi.cdef([[
      enum  {
	 HIREDIS_MAJOR       =  0,
	 HIREDIS_MINOR       = 10,
	 HIREDIS_PATCH       =  1,
	 REDIS_ERR           = -1,
	 REDIS_OK            =  0,
	 REDIS_ERR_IO        =  1,
	 REDIS_ERR_OTHER     =  2,
	 REDIS_ERR_EOF       =  3,
	 REDIS_ERR_PROTOCOL  =  4,
	 REDIS_ERR_OOM       =  5,
	 REDIS_BLOCK         = 0x01,
	 REDIS_CONNECTED     = 0x02,
	 REDIS_DISCONNECTING = 0x04,
	 REDIS_FREEING       = 0x08,
	 REDIS_IN_CALLBACK   = 0x10,
	 REDIS_SUBSCRIBED    = 0x20,
	 REDIS_REPLY_STRING  =  1,
	 REDIS_REPLY_ARRAY   =  2,
	 REDIS_REPLY_INTEGER =  3,
	 REDIS_REPLY_NIL     =  4,
	 REDIS_REPLY_STATUS  =  5,
	 REDIS_REPLY_ERROR   =  6,
      }
      
      typedef struct redisReply {
	 int                 type;
	 long long           integer;
	 int                 len; 
	 char*               str;
	 size_t              elements;
	 struct redisReply** element;
      } redisReply;
      
      typedef struct redisReadTask {
	 int                   type;
	 int                   elements;
	 int                   idx;
	 void*                 obj;
	 struct redisReadTask* parent;
	 void*                 privdata;
      } redisReadTask;
      
      typedef struct redisReplyObjectFunctions {
	 void *(*createString)(  const redisReadTask*, char*, size_t );
	 void *(*createArray)(   const redisReadTask*, int );
	 void *(*createInteger)( const redisReadTask*, long long );
	 void *(*createNil)(     const redisReadTask*);
	 void (*freeObject)(     void* );
      } redisReplyObjectFunctions;
      
      typedef struct redisReader {
	 int                        err;
	 char                       errstr[128];
	 char*                      buf;
	 size_t                     pos;
	 size_t                     len;
	 redisReadTask              rstack[9];
	 int                        ridx;
	 void*                      reply;
	 redisReplyObjectFunctions* fn;
	 void*                      privdata;
      } redisReader;

      typedef struct redisContext {
	 int err;
	 char errstr[128];
]] .. ((ffi.os == "Windows") and "void*" or "int") .. [[ fd;
	 int flags;
	 char *obuf;
	 redisReader *reader;
      } redisContext;

      redisReader*  redisReaderCreate(           );
      void          redisReaderFree(             redisReader*  );
      int           redisReaderFeed(             redisReader*, const char *buf, size_t len);
      int           redisReaderGetReply(         redisReader*, void **reply );
      void          freeReplyObject(             void* reply );
      int           redisvFormatCommand(         char **target, const char *format, va_list ap );
      int           redisFormatCommand(          char **target, const char *format, ... );
      int           redisFormatCommandArgv(      char **target, int argc, const char **argv, const size_t *argvlen );
      redisContext* redisConnect(                const char *ip, int port  );
      redisContext* redisConnectWithTimeout(     const char *ip, int port, struct timeval tv );
      redisContext* redisConnectNonBlock(        const char *ip, int port  );
      redisContext* redisConnectUnix(            const char *path  );
      redisContext* redisConnectUnixWithTimeout( const char *path, struct timeval tv );
      redisContext* redisConnectUnixNonBlock(    const char *path  );
      redisContext* redisConnected(              );
      redisContext* redisConnectedNonBlock(      );
      int           redisSetTimeout(             redisContext*, struct timeval tv );
      void          redisFree(                   redisContext*  );
      int           redisBufferRead(             redisContext*  );
      int           redisBufferWrite(            redisContext*, int *done );
      int           redisBufferReadDone(         redisContext*, char *buf, int nread );
      int           redisGetReply(               redisContext*, void **reply );
      int           redisGetReplyFromReader(     redisContext*, void **reply );
      int           redisvAppendCommand(         redisContext*, const char *format, va_list ap );
      int           redisAppendCommand(          redisContext*, const char *format, ... );
      int           redisAppendCommandArgv(      redisContext*, int argc, const char **argv, const size_t *argvlen );
      redisReply*   redisvCommand(               redisContext*, const char *format, va_list ap );
      redisReply*   redisCommand(                redisContext*, const char *format, ... );
      redisReply*   redisCommandArgv(            redisContext*, int argc, const char **argv, const size_t *argvlen );
]])

return hiredis
