local ffi = require( "ffi" )

local libs = ffi_apr_libs or {
   Windows = { x86 = "bin/Windows/x86/apr.dll", x64 = "bin/Windows/x64/apr.dll" },
   OSX     = { x86 = "bin/OSX/libapr.dylib", x64 = "bin/OSX/libapr.dylib" },
   Linux   = { x86 = "apr", x64 = "apr", arm = "apr" },
}

--local ffi_apr_lib = "/opt/local/lib/libapr-1.dylib"

local lib = ffi_apr_lib or libs[ ffi.os ][ ffi.arch ]
local apr = ffi.load( lib )

ffi.cdef [[
typedef int      apr_status_t;
typedef int32_t  apr_fileperms_t;
typedef int32_t  apr_dev_t;
typedef uint32_t apr_uid_t;
typedef uint32_t apr_gid_t;
typedef uint32_t apr_ino_t;
typedef uint64_t apr_off_t;
typedef uint64_t apr_time_t;
typedef struct   apr_pool_t         apr_pool_t;
typedef struct   ap_dir_t           apr_dir_t;
typedef struct   apr_file_t         apr_file_t;
typedef struct   apr_allocator_t    apr_allocator_t;
typedef struct   apr_memnode_t      apr_memnode_t;
typedef struct   apr_array_header_t apr_array_header_t;
typedef struct   apr_thread_mutex_t apr_thread_mutex_t;

typedef int (* apr_abortfunc_t)( int retcode );

typedef enum {
    APR_NOFILE,                                // no file type determined
    APR_REG,                                   // a regular file
    APR_DIR,                                   // a directory
    APR_CHR,                                   // a character device
    APR_BLK,                                   // a block device
    APR_PIPE,                                  // a FIFO / pipe
    APR_LNK,                                   // a symbolic link
    APR_SOCK,                                  // a [unix domain] socket
    APR_UNKFILE                 =        127   // a file of some other unknown type
} apr_filetype_e; 

enum {
    APR_FPROT_USETID            =     0x8000, // Set user id
    APR_FPROT_UREAD             =     0x0400, // Read by user
    APR_FPROT_UWRITE            =     0x0200, // Write by user
    APR_FPROT_UEXECUTE          =     0x0100, // Execute by user
    APR_FPROT_GSETID            =     0x4000, // Set group id
    APR_FPROT_GREAD             =     0x0040, // Read by group
    APR_FPROT_GWRITE            =     0x0020, // Write by group
    APR_FPROT_GEXECUTE          =     0x0010, // Execute by group
    APR_FPROT_WSTICKY           =     0x2000, // Sticky bit
    APR_FPROT_WREAD             =     0x0004, // Read by others
    APR_FPROT_WWRITE            =     0x0002, // Write by others
    APR_FPROT_WEXECUTE          =     0x0001, // Execute by others
    APR_FPROT_OS_DEFAULT        =     0x0FFF, // use OS's default permissions
    APR_FPROT_FILE_SOURCE_PERMS =     0x1000, // Copy source file's permissions
    APR_FINFO_LINK              = 0x00000001, // Stat the link not the file itself if it is a link
    APR_FINFO_MTIME             = 0x00000010, // Modification Time
    APR_FINFO_CTIME             = 0x00000020, // Creation or inode-changed time
    APR_FINFO_ATIME             = 0x00000040, // Access Time
    APR_FINFO_SIZE              = 0x00000100, // Size of the file
    APR_FINFO_CSIZE             = 0x00000200, // Storage size consumed by the file
    APR_FINFO_DEV               = 0x00001000, // Device
    APR_FINFO_INODE             = 0x00002000, // Inode
    APR_FINFO_NLINK             = 0x00004000, // Number of links
    APR_FINFO_TYPE              = 0x00008000, // Type
    APR_FINFO_USER              = 0x00010000, // User
    APR_FINFO_GROUP             = 0x00020000, // Group
    APR_FINFO_UPROT             = 0x00100000, // User protection bits
    APR_FINFO_GPROT             = 0x00200000, // Group protection bits
    APR_FINFO_WPROT             = 0x00400000, // World protection bits
    APR_FINFO_ICASE             = 0x01000000, // if dev is case insensitive
    APR_FINFO_NAME              = 0x02000000, // ->name in proper case
    APR_FINFO_MIN               = 0x00008170, // type, mtime, ctime, atime, size
    APR_FINFO_IDENT             = 0x00003000, // dev and inode
    APR_FINFO_OWNER             = 0x00030000, // user and group
    APR_FINFO_PROT              = 0x00700000, // all protections
    APR_FINFO_NORM              = 0x0073b170, // an atomic unix apr_stat()
    APR_FINFO_DIRENT            = 0x02000000, // an atomic unix apr_dir_read()
    APR_FILEPATH_NOTABOVEROOT   =       0x01, // Cause apr_filepath_merge to fail if addpath is above rootpath 
    APR_FILEPATH_SECUREROOTTEST =       0x02, // internal: Only meaningful with APR_FILEPATH_NOTABOVEROOT
    APR_FILEPATH_SECUREROOT     =       0x03, // Cause apr_filepath_merge to fail if addpath is above rootpath,
                                              // even given a rootpath /foo/bar and an addpath ../bar/bash
    APR_FILEPATH_NOTRELATIVE    =       0x04, // Fail apr_filepath_merge if the merged path is relative
    APR_FILEPATH_NOTABSOLUTE    =       0x08, // Fail apr_filepath_merge if the merged path is absolute
    APR_FILEPATH_NATIVE         =       0x10, // Return the file system's native path with path delimiters
    APR_FILEPATH_TRUENAME       =       0x20, // Resolve the true case of existing directories and file 
                                              // elements of addpath, (resolving any aliases on Win32)
                                              // and append a proper trailing slash if a directory
    APR_FILEPATH_ENCODING_UNKNOWN =        0, // The FilePath character encoding is unknown 
    APR_FILEPATH_ENCODING_LOCALE =         1, // The FilePath character encoding is locale-dependent
    APR_FILEPATH_ENCODING_UTF8   =         2, // The FilePath character encoding is UTF-8
    APR_ALLOCATOR_MAX_FREE_UNLIMITED =     0, // Symbolic constant

};

typedef struct apr_memnode_t {
    struct apr_memnode_t*  next;        // next memnode
    struct apr_memnode_t** ref;         // reference to self
    uint32_t               index;       // size
    uint32_t               free_index;  // how much free
    char*                  first_avail; // pointer to first free memory
    char*                  endp;        // pointer to end of free memory
} apr_memnode_t;

typedef struct apr_finfo_t {
    apr_pool_t*     pool;       // Allocates memory and closes lingering handles in the specified pool
    int32_t         valid;      // The bitmask describing valid fields of this apr_finfo_t structure 
                                //     including all available 'wanted' fields and potentially more
    apr_fileperms_t protection; // The access permissions of the file.  Mimics Unix access rights.
    apr_filetype_e  filetype;   // APR_REG, DIR, CHR, BLK, PIPE, LNK or SOCK.
                                // APR_NOFILE if the type is undetermined
                                // APR_UNKFILE if the type cannot be determined.
    apr_uid_t       user;       // The user id that owns the file
    apr_gid_t       group;      // The group id that owns the file
    apr_ino_t       inode;      // The inode of the file.
    apr_dev_t       device;     // The id of the device the file is on.
    int32_t         nlink;      // The number of hard links to the file.
    apr_off_t       size;       // The size of the file
    apr_off_t       csize;      // The storage size consumed by the file 
    apr_time_t      atime;      // The time the file was last accessed 
    apr_time_t      mtime;      // The time the file was last modified
    apr_time_t      ctime;      // The time the file was created, or the inode was last changed
    const char*     fname;      // The pathname of the file (possibly unrooted)
    const char*     name;       // The file's name (no path) in filesystem case
    apr_file_t*     filehand;   // The file's handle, if accessed (can be submitted to apr_duphandle)
} apr_finfo_t;

apr_status_t        apr_initialize();
apr_status_t        apr_app_initialize( int *argc, char const* const** argv, char const* const** env );
void                apr_terminate(void);
void                apr_terminate2(void);

apr_status_t        apr_pool_initialize();
void                apr_pool_terminate();
apr_status_t        apr_pool_create_ex(       apr_pool_t**, apr_pool_t*, apr_abortfunc_t, apr_allocator_t* );
apr_status_t        apr_pool_create_ex_debug( apr_pool_t**, apr_pool_t*, apr_abortfunc_t, apr_allocator_t*, 
                                              const char* file_line );
apr_status_t        apr_pool_create_unmanaged_ex(       apr_pool_t**, apr_abortfunc_t, apr_allocator_t* );
apr_status_t        apr_pool_create_unmanaged_ex_debug( apr_pool_t**, apr_abortfunc_t, apr_allocator_t*,
                                                        const char* file_line );
apr_allocator_t*    apr_pool_allocator_get( apr_pool_t*  );
void                apr_pool_clear(         apr_pool_t*  );
void                apr_pool_clear_debug(   apr_pool_t*, const char* file_line );
void                apr_pool_destroy(       apr_pool_t*  );
void                apr_pool_destroy_debug( apr_pool_t*, const char* file_line );
void                apr_pool_abort_set(     apr_abortfunc_t, apr_pool_t* );
apr_abortfunc_t     apr_pool_abort_get(     apr_pool_t* );
apr_pool_t*         apr_pool_parent_get(    apr_pool_t* );
int                 apr_pool_is_ancestor(   apr_pool_t*, apr_pool_t* );
void                apr_pool_tag(           apr_pool_t*, const char* );
apr_status_t        apr_pool_userdata_set(  const void* data, const char* key,
                                            apr_status_t (*cleanup)(void *), apr_pool_t* );
apr_status_t        apr_pool_userdata_setn( const void* data, const char* key,
                                            apr_status_t (*cleanup)(void *), apr_pool_t* );
apr_status_t        apr_pool_userdata_get(  void **data, const char *key, apr_pool_t* );

void*               apr_palloc(        apr_pool_t*, size_t size );
void*               apr_palloc_debug(  apr_pool_t*, size_t size, const char* file_line );
void*               apr_pcalloc(       apr_pool_t*, size_t size );
void*               apr_pcalloc_debug( apr_pool_t*, size_t size, const char* file_line );

apr_status_t        apr_allocator_create(       apr_allocator_t** allocator );
void                apr_allocator_destroy(      apr_allocator_t*  allocator );
apr_memnode_t*      apr_allocator_alloc(        apr_allocator_t*  allocator, size_t size );
void                apr_allocator_free(         apr_allocator_t*  allocator, apr_memnode_t* memnode );
void                apr_allocator_owner_set(    apr_allocator_t*  allocator, apr_pool_t *pool);
apr_pool_t*         apr_allocator_owner_get(    apr_allocator_t*  allocator);
void                apr_allocator_max_free_set( apr_allocator_t*  allocator, size_t size );
void                apr_allocator_mutex_set(    apr_allocator_t*  allocator,apr_thread_mutex_t* );
apr_thread_mutex_t* apr_allocator_mutex_get(    apr_allocator_t*  );

apr_status_t        apr_dir_open(   apr_dir_t** new_dir, const char *dirname, apr_pool_t* );
apr_status_t        apr_dir_close(  apr_dir_t*  the_dir );
apr_status_t        apr_dir_rewind( apr_dir_t*  the_dir );
apr_status_t        apr_dir_read(   apr_finfo_t* finfo, int32_t wanted, apr_dir_t* the_dir );

apr_status_t        apr_stat(       apr_finfo_t* finfo, const char* fname, int32_t wanted, apr_pool_t* );

apr_status_t        apr_filepath_list_split( apr_array_header_t** pathelts, const char* liststr, apr_pool_t* );
apr_status_t        apr_filepath_list_merge( char** liststr, apr_array_header_t *pathelts, apr_pool_t* );
apr_status_t        apr_filepath_get(        char** path, int32_t flags, apr_pool_t* );
apr_status_t        apr_filepath_set(        const char* path, apr_pool_t* );
apr_status_t        apr_filepath_encoding(   int* style, apr_pool_t* );
apr_status_t        apr_filepath_root( const char** rootpth, const char** filepth, int32_t flgs, apr_pool_t* );
apr_status_t        apr_filepath_merge(      char** newpath,  const char* rootpath,  const char *addpath, 
                                             int32_t flags, apr_pool_t *);

apr_status_t        apr_uid_current(      apr_uid_t* uid, apr_gid_t* gid, apr_pool_t* );
apr_status_t        apr_uid_get(          apr_uid_t* uid, apr_gid_t* gid, const char *username, apr_pool_t* );
apr_status_t        apr_uid_name_get(     char** username, apr_uid_t userid, apr_pool_t* );
apr_status_t        apr_uid_homepath_get( char** dirname, const char *username, apr_pool_t* );
apr_status_t        apr_uid_compare(      apr_uid_t left, apr_uid_t right );
apr_status_t        apr_gid_name_get(     char **groupname, apr_gid_t gid, apr_pool_t* );
apr_status_t        apr_gid_get(          apr_gid_t* gid, const char* groupname, apr_pool_t* );
apr_status_t        apr_gid_compare(      apr_gid_t left, apr_gid_t right );
]]

return apr

