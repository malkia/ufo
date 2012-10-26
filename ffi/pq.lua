local ffi = require( "ffi" )

--[[
   From http://pgolub.wordpress.com/2010/09/21/libpq-stands-for/

   I always was interested why PostgreSQL client library named "libpq". Of course
I guessed that "lib" means "library", but there are two more characters left. I 
supposed that "p" is some how connected with "Postgres". But I have no any idea 
why "q" appeared in the library name.

   Now I know the answer. Thanks to Bruce Momjian:

   Libpq is called "libpq" because of the original use of the QUEL query language,
i.e. lib Post-QUEL. We have a proud backward-compatibility history with this
library. [ http://archives.postgresql.org/pgsql-docs/2010-09/msg00081.php ]
--]]

--[[
NOTES: Some structure/enum names were changed to be more namespace friendly (starting with PQ or PG)
       PG_FILE is really the <stdio.h> FILE
--]]

ffi.cdef [[
   typedef struct PG_FILE PG_FILE; // This is really FILE

   typedef unsigned PGOid;
   static const PGOid PG_INVALID_OID = 0;

   static const char PG_DIAG_SEVERITY           = 0x53; // 'S'
   static const char PG_DIAG_SQLSTATE           = 0x43; // 'C'
   static const char PG_DIAG_MESSAGE_PRIMARY    = 0x4D; // 'M'
   static const char PG_DIAG_MESSAGE_DETAIL     = 0x44; // 'D'
   static const char PG_DIAG_MESSAGE_HINT       = 0x48; // 'H'
   static const char PG_DIAG_STATEMENT_POSITION = 0x50; // 'P'
   static const char PG_DIAG_INTERNAL_POSITION  = 0x70; // 'p'
   static const char PG_DIAG_INTERNAL_QUERY     = 0x71; // 'q'
   static const char PG_DIAG_CONTEXT            = 0x57; // 'W'
   static const char PG_DIAG_SOURCE_FILE        = 0x46; // 'F'
   static const char PG_DIAG_SOURCE_LINE        = 0x4C; // 'L'
   static const char PG_DIAG_SOURCE_FUNCTION    = 0x52; // 'R'

   enum {
     PG_COPYRES_ATTRS       = 0x01,
     PG_COPYRES_TUPLES      = 0x02, // Implies PG_COPYRES_ATTRS
     PG_COPYRES_EVENTS      = 0x04, 
     PG_COPYRES_NOTICEHOOKS = 0x08
   };

   typedef enum PGConnStatus {
     PG_CONNECTION_OK,
     PG_CONNECTION_BAD,
     PG_CONNECTION_STARTED,
     PG_CONNECTION_MADE,
     PG_CONNECTION_AWAITING_RESPONSE,
     PG_CONNECTION_AUTH_OK,
     PG_CONNECTION_SETENV,	
     PG_CONNECTION_SSL_STARTUP,
     PG_CONNECTION_NEEDED
   } PGConnStatus;
   
   typedef enum PGPollStatus {
     PGRES_POLLING_FAILED,
     PGRES_POLLING_READING,
     PGRES_POLLING_WRITING,
     PGRES_POLLING_OK,
     PGRES_POLLING_ACTIVE
   } PGPollStatus;

   typedef enum PGExecStatus {
     PGRES_EMPTY_QUERY,
     PGRES_COMMAND_OK,
     PGRES_TUPLES_OK,
     PGRES_COPY_OUT,
     PGRES_COPY_IN,
     PGRES_BAD_RESPONSE,
     PGRES_NONFATAL_ERROR,
     PGRES_FATAL_ERROR,
     PGRES_COPY_BOTH,
     PGRES_SINGLE_TUPLE
   } PGExecStatus;

   typedef enum PGTransStatus {
     PQTRANS_IDLE,
     PQTRANS_ACTIVE,
     PQTRANS_INTRANS,
     PQTRANS_INERROR,
     PQTRANS_UNKNOWN
   } PGTransStatus;

   typedef enum PGVerbosity {
     PQERRORS_TERSE,
     PQERRORS_DEFAULT,
     PQERRORS_VERBOSE
   } PGVerbosity;

   typedef enum PGPing {
     PQPING_OK,
     PQPING_REJECT,
     PQPING_NO_RESPONSE,
     PQPING_NO_ATTEMPT
   } PGPing;

   typedef struct PGconn   PGconn;
   typedef struct PGresult PGresult;
   typedef struct PGcancel PGcancel;

   typedef struct PGnotify {
     char*            relname;
     int              be_pid;
     char*            extra;
     struct PGNotify* next;
   } PGnotify;

   typedef struct PQprintOpt {
     char   header;
     char   align;
     char   standard;
     char   html3;
     char   expanded;
     char   pager;
     char*  fieldSep;
     char*  tableOpt;
     char*  caption;
     char** fieldName; 
   } PQprintOpt;

   typedef void (* PQnoticeRecv)( void *arg, const PGresult *res );
   typedef void (* PQnoticeProc)( void *arg, const char *message );

   typedef struct PQconnOpt {
     char* keyword;
     char* envvar;
     char* compiled;
     char* val;
     char* label;
     char* dispchar;
     int   dispsize;
   } PQconnOpt;

   typedef struct PQArgBlock {
     int len;
     int isint;
     union {
      int *ptr;
      int integer;
     } u;
   } PQArgBlock;

   typedef struct PGresAttDesc {
     char* name;
     PGOid tableid;
     int   columnid;
     int   format;
     PGOid typid;
     int   typlen;
     int   atttypmod;
   } PGresAttDesc;

   typedef void (*pgthreadlock_t) (int acquire);
   pgthreadlock_t PQregisterThreadLock(pgthreadlock_t newhandler);

   PGconn*        PQconnectStart(        const char* conninfo );
   PGconn*        PQconnectStartParams(  const char* const* keywords, const char* const* values, int expand_dbname );
   PGPollStatus   PQconnectPoll(               PGconn* );
   PGconn*        PQconnectdb(           const char *conninfo );
   PGconn*        PQconnectdbParams(     const char *const* keywords, const char *const* values, int expand_dbname);
   PGconn*        PQsetdbLogin(          const char *pghost, const char *pgport, const char *pgoptions, const char *pgtty, const char *dbName,  const char *login, const char *pwd);
   void           PQfinish(                    PGconn* );
   PQconnOpt*     PQconndefaults(              );	 
   PQconnOpt*     PQconninfoParse(       const char *conninfo, char **errmsg );
   void           PQconninfoFree(              PQconnOpt* );
   int            PQresetStart(                PGconn* );
   PGPollStatus   PQresetPoll(                 PGconn* );
   void           PQreset(                     PGconn* );
   PGcancel*      PQgetCancel(                 PGconn* );
   void           PQfreeCancel(                PGcancel* );
   int	          PQcancel(                    PGcancel*, char *errbuf, int errbufsize );
   int	          PQrequestCancel(             PGconn* );
   char*          PQdb(                  const PGconn*);
   char*          PQuser(                const PGconn*);
   char*          PQpass(                const PGconn*);
   char*          PQhost(                const PGconn*);
   char*          PQport(                const PGconn*);
   char*          PQtty(                 const PGconn*);
   char*          PQoptions(             const PGconn*);
   PGConnStatus   PQstatus(              const PGconn*);
   PGTransStatus  PQtransactionStatus(   const PGconn*);
   const char*    PQparameterStatus(     const PGconn*, const char *paramName);
   int	          PQprotocolVersion(     const PGconn*);
   int	          PQserverVersion(       const PGconn*);
   char*          PQerrorMessage(        const PGconn*);
   int	          PQsocket(              const PGconn*);
   int	          PQbackendPID(          const PGconn*);
   int	          PQconnectionNeedsPassword(   const PGconn* );
   int	          PQconnectionUsedPassword(    const PGconn* );
   int	          PQclientEncoding(     const  PGconn*);
   int	          PQsetClientEncoding(         PGconn*, const char *encoding);
   void*          PQgetssl(                    PGconn*);
   void           PQinitSSL(                   int do_init);
   void           PQinitOpenSSL(               int do_ssl, int do_crypto);
   PGVerbosity    PQsetErrorVerbosity(         PGconn*, PGVerbosity );
   PQnoticeRecv   PQsetNoticeReceiver(         PGconn*, PQnoticeRecv, void *arg);
   PQnoticeProc   PQsetNoticeProcessor(        PGconn*, PQnoticeProc, void *arg);
   void           PQtrace(                     PGconn*, PG_FILE *debug_port );
   void           PQuntrace(                   PGconn*  );
   PGresult*      PQexec(                      PGconn*, const char *query );
   PGresult*      PQexecParams(                PGconn*, const char* cmd, int nParams, const PGOid *paramTypes, const char *const * paramValues, const int *paramLengths, const int *paramFormats, int resultFormat );
   PGresult*      PQprepare(                   PGconn*, const char* stmtName, const char *query, int nParams, const PGOid *paramTypes );
   PGresult*      PQexecPrepared(              PGconn*, const char* stmtName, int nParams, const char *const* paramValues, const int *paramLengths, const int *paramFormats, int resultFormat );
   int	          PQsendQuery(                 PGconn*, const char *query);
   int            PQsendQueryParams(           PGconn*, const char* cmd, int nParams, const PGOid *paramTypes, const char *const * paramValues, const int *paramLengths, const int *paramFormats, int resultFormat );
   int            PQsendPrepare(               PGconn*, const char *stmtName, const char *query, int nParams, const PGOid *paramTypes );
   int            PQsendQueryPrepared(         PGconn*, const char *stmtName, int nParams, const char *const * paramValues, const int *paramLengths, const int *paramFormats, int resultFormat );
   int	          PQsetSingleRowMode(          PGconn*  );
   PGresult*      PQgetResult(                 PGconn*  );
   int	          PQisBusy(                    PGconn*  );
   int	          PQconsumeInput(              PGconn*  );
   PGnotify*      PQnotifies(                  PGconn*  );
   int            PQputCopyData(               PGconn*, const char* buffer, int nbytes );
   int            PQputCopyEnd(                PGconn*, const char* errormsg );
   int            PQgetCopyData(               PGconn*, char** buffer, int async );
   int            PQgetline(                   PGconn*, char* string, int length );
   int            PQputline(                   PGconn*, const char* string );
   int            PQgetlineAsync(              PGconn*, char* buffer, int bufsize );
   int            PQputnbytes(                 PGconn*, const char *buffer, int nbytes);
   int            PQQendcopy(                  PGconn*  );
   int            PQsetnonblocking(            PGconn*, int arg );
   int            PQisnonblocking(             const PGconn*  );
   int            PQisthreadsafe(              );
   PGPing         PQping(                const char* conninfo);
   PGPing         PQpingParams(          const char* const* keywords, const char *const* values, int expand_dbname );
   int	          PQflush(                     PGconn*  );
   PGresult*      PQfn(                        PGconn*, int fnid, int* result_buf, int* result_len, int result_is_int, const PQArgBlock* args, int nargs );
   PGExecStatus   PQresultStatus(        const PGresult*  );
   char*          PQresStatus(                 PGExecStatus );
   char*          PQresultErrorMessage(  const PGresult*  );
   char*          PQresultErrorField(    const PGresult*, int fieldcode );
   int            PQntuples(             const PGresult*  );
   int            PQnfields(             const PGresult*  );
   int            PQbinaryTuples(        const PGresult*  );
   char*          PQfname(               const PGresult*, int field_num );
   int            PQfnumber(             const PGresult*, const char *field_name );
   PGOid          PQftable(              const PGresult*, int field_num );
   int            PQftablecol(           const PGresult*, int field_num );
   int            PQfformat(             const PGresult*, int field_num );
   PGOid          PQftype(               const PGresult*, int field_num );
   int            PQfsize(               const PGresult*, int field_num );
   int            PQfmod(                const PGresult*, int field_num );
   char*          PQcmdStatus(                 PGresult*  );
   char*          PQoidStatus(           const PGresult*  );
   PGOid          PQoidValue(            const PGresult*  );
   char*          PQcmdTuples(                 PGresult*  );
   char*          PQgetvalue(            const PGresult*, int tup_num, int field_num);
   int            PQgetlength(           const PGresult*, int tup_num, int field_num);
   int            PQgetisnull(           const PGresult*, int tup_num, int field_num);
   int            PQnparams(             const PGresult*  );
   PGOid          PQparamtype(           const PGresult*, int param_num );
   PGresult*      PQdescribePrepared(          PGconn*, const char* stmt );
   PGresult*      PQdescribePortal(            PGconn*, const char* portal );
   int	          PQsendDescribePrepared(      PGconn*, const char* stmt );
   int	          PQsendDescribePortal(        PGconn*, const char* portal );
   void           PQclear(                     PGresult* );
   void           PQfreemem(                   void *ptr );
   PGresult*      PQmakeEmptyPGresult(         PGconn*, PGExecStatus );
   PGresult*      PQcopyResult(          const PGresult*, int flags );
   int            PQsetResultAttrs(            PGresult*, int numAttributes, PGresAttDesc* );
   void*          PQresultAlloc(               PGresult*, size_t nBytes );
   int            PQsetvalue(                  PGresult*, int tup_num, int field_num, char* value, int len );
   size_t         PQescapeStringConn(          PGconn*, char *to, const char *from, size_t length, int *error );
   char*          PQescapeLiteral(             PGconn*, const char* str, size_t len );
   char*          PQescapeIdentifier(          PGconn*, const char* str, size_t len );
   uint8_t*       PQescapeByteaConn(           PGconn*, const uint8_t* from, size_t from_length, size_t *to_length );
   uint8_t*       PQunescapeBytea(             const unsigned char *strtext, size_t *retbuflen );
   size_t         PQescapeString(              char *to, const char *from, size_t length );
   uint8_t*       PQescapeBytea(               const uint8_t* from, size_t from_length, size_t *to_length );
   void           PQprint(                     PG_FILE*, const PGresult*, const PQprintOpt* );
   void           PQdisplayTuples(             const PGresult*, PG_FILE*, int fillAlign, const char *fieldSep, int printHeader, int quiet );
   void           PQprintTuples(               const PGresult*, PG_FILE*, int printAttName, int terseOutput, int width);
   int	          lo_open(                     PGconn*, PGOid lobjId, int mode);
   int	          lo_close(                    PGconn*, int fd);
   int	          lo_read(                     PGconn*, int fd, char *buf, size_t len);
   int	          lo_write(                    PGconn*, int fd, const char *buf, size_t len);
   int	          lo_lseek(                    PGconn*, int fd, int offset, int whence);
   int64_t        lo_lseek64(                  PGconn*, int fd, int64_t offset, int whence);
   PGOid          lo_creat(                    PGconn*, int mode);
   PGOid          lo_create(                   PGconn*, PGOid lobjId);
   int	          lo_tell(                     PGconn*, int fd);
   int64_t        lo_tell64(                   PGconn*, int fd);
   int            lo_truncate(                 PGconn*, int fd, size_t len);
   int	          lo_truncate64(               PGconn*, int fd, int64_t len);
   int	          lo_unlink(                   PGconn*, PGOid lobjId);
   PGOid          lo_import(                   PGconn*, const char *filename);
   PGOid          lo_import_with_oid(          PGconn*, const char *filename, PGOid lobjId);
   int            lo_export(                   PGconn*, PGOid lobjId, const char *filename);
   int            PQlibVersion(                );            
   int            PQmblen(                     const char *s, int encoding);
   int            PQdsplen(                    const char *s, int encoding );
   int            PQenv2encoding(              );           
   char*          PQencryptPassword(           const char *passwd, const char *user );
   int            pg_char_to_encoding(         const char *name );
   const char*    pg_encoding_to_char(         int encoding );
   int	          pg_valid_server_encoding_id( int encoding );
]]

return ffi.load( "pq" )

