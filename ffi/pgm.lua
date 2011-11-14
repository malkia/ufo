
enum {
   PGM_ERROR_DOMAIN_IF,
   PGM_ERROR_DOMAIN_PACKET,
   PGM_ERROR_DOMAIN_RECV,
   PGM_ERROR_DOMAIN_TIME,
   PGM_ERROR_DOMAIN_SOCKET,
   PGM_ERROR_DOMAIN_ENGINE,
   PGM_ERROR_DOMAIN_HTTP,
   PGM_ERROR_DOMAIN_SNMP
};

enum {
   PGM_ERROR_ADDRFAMILY,
   PGM_ERROR_AFNOSUPPORT,
   PGM_ERROR_AGAIN,
   PGM_ERROR_BADE,
   PGM_ERROR_BADF,
   PGM_ERROR_BOUNDS,
   PGM_ERROR_CKSUM,
   PGM_ERROR_CONNRESET,
   PGM_ERROR_FAIL,
   PGM_ERROR_FAULT,
   PGM_ERROR_INPROGRESS,	
   PGM_ERROR_INTR,
   PGM_ERROR_INVAL,
   PGM_ERROR_MFILE,
   PGM_ERROR_NFILE,
   PGM_ERROR_NOBUFS,		
   PGM_ERROR_NODATA,		
   PGM_ERROR_NODEV,
   PGM_ERROR_NOENT,
   PGM_ERROR_NOMEM,
   PGM_ERROR_NONAME,		
   PGM_ERROR_NONET,
   PGM_ERROR_NOPROTOOPT,
   PGM_ERROR_NOSYS,		
   PGM_ERROR_NOTUNIQ,
   PGM_ERROR_NXIO,
   PGM_ERROR_PERM,
   PGM_ERROR_PROCLIM,		
   PGM_ERROR_PROTO,
   PGM_ERROR_RANGE,
   PGM_ERROR_SERVICE,		
   PGM_ERROR_SOCKTNOSUPPORT,	
   PGM_ERROR_SYSNOTAREADY,	
   PGM_ERROR_SYSTEM,		
   PGM_ERROR_VERNOTSUPPORTED,	
   PGM_ERROR_XDEV,
   PGM_ERROR_FAILED		
};

enum {
   PGM_LOG_ROLE_MEMORY             = 0x001,
   PGM_LOG_ROLE_NETWORK            = 0x002,
   PGM_LOG_ROLE_CONFIGURATION      = 0x004,
   PGM_LOG_ROLE_SESSION            = 0x010,
   PGM_LOG_ROLE_NAK                = 0x020,
   PGM_LOG_ROLE_RATE_CONTROL       = 0x040,
   PGM_LOG_ROLE_TX_WINDOW          = 0x080,
   PGM_LOG_ROLE_RX_WINDOW          = 0x100,
   PGM_LOG_ROLE_FEC                = 0x400,
   PGM_LOG_ROLE_CONGESTION_CONTROL = 0x800
};

enum {
   PGM_LOG_LEVEL_DEBUG     = 0,
   PGM_LOG_LEVEL_TRACE     = 1,
   PGM_LOG_LEVEL_MINOR     = 2,
   PGM_LOG_LEVEL_NORMAL    = 3,
   PGM_LOG_LEVEL_WARNING   = 4,
   PGM_LOG_LEVEL_ERROR     = 5,
   PGM_LOG_LEVEL_FATAL     = 6
};

extern const unsigned pgm_major_version;
extern const unsigned pgm_minor_version;
extern const unsigned pgm_micro_version;
extern const char*    pgm_build_date;
extern const char*    pgm_build_time;
extern const char*    pgm_build_system;
extern const char*    pgm_build_machine;
extern const char*    pgm_build_revision;
extern int            pgm_log_mask;
extern int            pgm_min_log_level;
extern bool           pgm_mem_gc_friendly;

typedef void (*pgm_log_func_t) (const int, const char*restrict, void*restrict);


typedef struct pgm_list_t {
   void*                   data;
   struct pgm_list_t*      next;
   struct pgm_list_t*      prev;
} pgm_list_t;

typedef struct pgm_error_t {
   int	  domain;
   int	  code;
   char*  message;
} pgm_error_t;

bool  pgm_init(           pgm_error_t** );
bool  pgm_supported(      );
bool  pgm_shutdown(       );
void  pgm_drop_superuser( );

void* pgm_malloc(    const size_t  );
void* pgm_malloc_n(  const size_t, const size_t );
void* pgm_malloc0(   const size_t  );
void* pgm_malloc0_n( const size_t, const size_t );
void* pgm_memdup(    const void*,  const size_t );
void* pgm_realloc(         void*,  const size_t );
void  pgm_free(            void*   );

void  pgm_messages_init(     );
void  pgm_messages_shutdown( );
pgm_log_func_t
      pgm_log_set_handler(   pgm_log_func_t, void* );

void pgm_error_free (pgm_error_t*);
void pgm_set_error (pgm_error_t**restrict, const int, const int, const char*restrict, ...) PGM_GNUC_PRINTF (4, 5);
void pgm_propagate_error (pgm_error_t**restrict, pgm_error_t*restrict);
void pgm_clear_error (pgm_error_t**);
void pgm_prefix_error (pgm_error_t**restrict, const char*restrict, ...) PGM_GNUC_PRINTF (2, 3);
int  pgm_error_from_errno (const int) PGM_GNUC_CONST;
int  pgm_error_from_h_errno (const int) PGM_GNUC_CONST;
int  pgm_error_from_eai_errno (const int, const int) PGM_GNUC_CONST;
int  pgm_error_from_wsa_errno (const int) PGM_GNUC_CONST;
int  pgm_error_from_win_errno (const int) PGM_GNUC_CONST;

//#define PGM_GSISTRLEN           (sizeof("000.000.000.000.000.000"))
//#define PGM_GSI_INIT            {{ 0, 0, 0, 0, 0, 0 }}
//#define PGM_TSISTRLEN           (sizeof("000.000.000.000.000.000.00000"))
//#define PGM_TSI_INIT            { PGM_GSI_INIT, 0 }

typedef struct pgm_gsi_t {
   uint8_t identifier[6];
} pgm_gsi_t;

typedef struct pgm_tsi_t {
   pgm_gsi_t   gsi;
   uint16_t    sport;
} pgm_tsi_t;

bool  pgm_gsi_create_from_hostname( pgm_gsi_t*, pgm_error_t** );
bool  pgm_gsi_create_from_addr(     pgm_gsi_t*, pgm_error_t** );
bool  pgm_gsi_create_from_data(     pgm_gsi_t*, const uint8_t*, const size_t );
bool  pgm_gsi_create_from_string(   pgm_gsi_t*, const char*,         ssize_t );
int   pgm_gsi_print_r(        const pgm_gsi_t*, char*,          const size_t );
char* pgm_gsi_print(          const pgm_gsi_t*  );
bool  pgm_gsi_equal(   const void*restrict, const void*restrict);
char* pgm_tsi_print(   const pgm_tsi_t*);
int   pgm_tsi_print_r( const pgm_tsi_t*restrict, char*restrict, size_t);
bool  pgm_tsi_equal(   const void*restrict, const void*restrict);

bool pgm_http_init (uint16_t, pgm_error_t**);
bool pgm_http_shutdown (void);
void pgm_if_print_all (void);

PGM_STATIC_ASSERT(sizeof(struct pgm_tsi_t) == 8);

