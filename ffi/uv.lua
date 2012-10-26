local ffi  = require( "ffi" )

local libs = ffi_uv_libs or {
   OSX     = { x86 = "bin/OSX/uv.dylib",       x64 = "bin/OSX/uv.dylib" },
   Windows = { x86 = "bin/Windows/x86/uv.dll", x64 = "bin/Windows/x64/uv.dll" }
			    }

local lib = ffi_uv_lib or libs[ ffi.os ][ ffi.arch ] or "uv"
local uv = ffi.load( lib )

assert --ffi.cdef
[[
   typedef enum uv_err_code {
   UV_UKNOWN = -1,
   UV_OK,
   UV_EOF,
   UV_EADDRINFO,
   UV_EACCES,
   UV_EAGAIN,
   UV_EADDRINUSE,
   UV_EADDRNOTAVAIL,
   UV_EAFNOSUPPORT,
   UV_EALREADY,
   UV_EBADF,
   UV_EBUSY,
   UV_ECONNABORTED,
   UV_ECONNREFUSED,
   UV_ECONNRESET,
   UV_EDESTADDRREQ,
   UV_EFAULT,
   UV_EHOSTUNREACH,
   UV_EINTR,
   UV_EINVAL,
   UV_EISCONN,
   UV_EMFILE,
   UV_EMSGSIZE,
   UV_ENETDOWN,
   UV_ENETUNREACH,
   UV_ENFILE,
   UV_ENOBUFS,
   UV_ENOMEM,
   UV_ENOTDIR,
   UV_EISDIR,
   UV_ENONET,
   UV_ENOTCONN,
   UV_ENOTSOCK,
   UV_ENOTSUP,
   UV_ENOENT,
   UV_ENOSYS,
   UV_EPIPE,
   UV_EPROTO,
   UV_EPROTONOSUPPORT,
   UV_EPROTOTYPE,
   UV_ETIMEDOUT,
   UV_ECHARSET,
   UV_EAIFAMNOSUPPORT,
   UV_EAISERVICE,
   UV_EAISOCKTYPE,
   UV_ESHUTDOWN,
   UV_EEXIST,
   UV_ESRCH,
   UV_ENAMETOOLONG,
   UV_EPERM,
   UV_ELOOP,
   UV_EXDEV,
   UV_ENOTEMPTY,
   UV_ENOSPC,
   UV_EIO,
   UV_EROFS,
   UV_ENODEV,
   UV_ESPIPE,
   UV_ECANCELED,
   UV_MAX_ERRORS
   } uv_err_code;

   typedef enum uv_handle_type {
   UV_UNKNOWN_HANDLE,
   UV_ASYNC,
   UV_CHECK,
   UV_FS_EVENT,
   UV_FS_POLL,
   UV_IDLE,
   UV_NAMED_PIPE,
   UV_POLL,
   UV_PREPARE,
   UV_PROCESS,
   UV_TCP,
   UV_TIMER,
   UV_TTY,
   UV_UDP,
   UV_SIGNAL,
   UV_FILE,
   UV_HANDLE_TYPE_MAX
   } uv_handle_type;
 
   typedef enum uv_req_type {
   UV_UNKNOWN_REQ,
   UV_CONNECT,
   UV_WRITE,
   UV_SHUTDOWN,
   UV_UDP_SEND,
   UV_FS,
   UV_WORK,
   UV_GETADDRINFO,
   //UV_REQ_TYPE_PRIVATE,
   UV_REQ_TYPE_MAX
   } uv_req_type;

   typedef enum uv_membership {
   UV_LEAVE_GROUP = 0,
   UV_JOIN_GROUP
   } uv_membership;

   typedef enum uv_udp_flags {
   UV_UDP_IPV6ONLY = 1,
   UV_UDP_PARTIAL = 2
   } uv_udp_flags;
   
   typedef struct uv_buf_t {
   int blah;
   } uv_buf_t;

   typedef struct uv_statbuf_t {
   int blah;
   } uv_statbuf_t;

   typedef size_t ssize_t;

   typedef struct uv_loop_s              uv_loop_t;
   typedef struct uv_err_s               uv_err_t;
   typedef struct uv_handle_s            uv_handle_t;
   typedef struct uv_stream_s            uv_stream_t;
   typedef struct uv_tcp_s               uv_tcp_t;
   typedef struct uv_udp_s               uv_udp_t;
   typedef struct uv_pipe_s              uv_pipe_t;
   typedef struct uv_tty_s               uv_tty_t;
   typedef struct uv_poll_s              uv_poll_t;
   typedef struct uv_timer_s             uv_timer_t;
   typedef struct uv_prepare_s           uv_prepare_t;
   typedef struct uv_check_s             uv_check_t;
   typedef struct uv_idle_s              uv_idle_t;
   typedef struct uv_async_s             uv_async_t;
   typedef struct uv_process_s           uv_process_t;
   typedef struct uv_fs_event_s          uv_fs_event_t;
   typedef struct uv_fs_poll_s           uv_fs_poll_t;
   typedef struct uv_signal_s            uv_signal_t;
   typedef struct uv_req_s               uv_req_t;
   typedef struct uv_getaddrinfo_s       uv_getaddrinfo_t;
   typedef struct uv_shutdown_s          uv_shutdown_t;
   typedef struct uv_write_s             uv_write_t;
   typedef struct uv_connect_s           uv_connect_t;
   typedef struct uv_udp_send_s          uv_udp_send_t;
   typedef struct uv_fs_s                uv_fs_t;
   typedef struct uv_work_s              uv_work_t;
   typedef struct uv_counters_s          uv_counters_t;
   typedef struct uv_cpu_info_s          uv_cpu_info_t;
   typedef struct uv_interface_address_s uv_interface_address_t;

   typedef struct sockaddr;
   typedef struct sockaddr_in;
   typedef struct sockaddr_in6;

   typedef void* uv_file;

   typedef uv_buf_t (* uv_alloc_cb   )( uv_handle_t*    handle,  size_t suggested_size );
   typedef void (* uv_read_cb        )( uv_stream_t*    stream, ssize_t nread, uv_buf_t );
   typedef void (* uv_read2_cb       )( uv_pipe_t*      pipe,   ssize_t nread, uv_buf_t, uv_handle_type pending );
   typedef void (* uv_write_cb       )( uv_write_t*     req,        int status );
   typedef void (* uv_connect_cb     )( uv_connect_t*   req,        int status );
   typedef void (* uv_shutdown_cb    )( uv_shutdown_t*  req,        int status );
   typedef void (* uv_connection_cb  )( uv_stream_t*    server,     int status );
   typedef void (* uv_close_cb       )( uv_handle_t*    handle                 );
   typedef void (* uv_timer_cb       )( uv_timer_t*     handle,     int status );
   typedef void (* uv_async_cb       )( uv_async_t*     handle,     int status );
   typedef void (* uv_prepare_cb     )( uv_prepare_t*   handle,     int status );
   typedef void (* uv_check_cb       )( uv_check_t*     handle,     int status );
   typedef void (* uv_idle_cb        )( uv_idle_t*      handle,     int status );
   typedef void (* uv_exit_cb        )( uv_process_t*   process,    int exit_status, int term_signal );
   typedef void (* uv_walk_cb        )( uv_handle_t*    handle, void* arg );
   typedef void (* uv_fs_cb          )( uv_fs_t*        req );
   typedef void (* uv_work_cb        )( uv_work_t*      req );
   typedef void (* uv_after_work_cb  )( uv_work_t*      req );
   typedef void (* uv_getaddrinfo_cb )( uv_getaddrinfo_t* h, int status, struct addrinfo* res );
   typedef void (* uv_fs_event_cb    )( uv_fs_event_t*    h, const char* filename, int events, int status );
   typedef void (* uv_fs_poll_cb     )( uv_fs_poll_t*     h, int status,
   const uv_statbuf_t* prev, const uv_statbuf_t* curr );
   typedef void (* uv_signal_cb      )( uv_signal_t*      h, int signum );
   typedef void (* uv_udp_send_cb    )( uv_udp_send_t*  req, int status );
   typedef void (* uv_udp_recv_cb    )( uv_udp_t*         h, ssize_t nread, uv_buf_t buf,
   struct sockaddr* addr, unsigned flags );

   typedef struct uv_err_s {
   uv_err_code code;
   int         sys_errno_;
   } uv_err_s;

   typedef void (*uv_udp_send_cb)(uv_udp_send_t* req, int status);
   typedef void (*uv_udp_recv_cb)(uv_udp_t* handle, ssize_t nread, uv_buf_t buf,
   struct sockaddr* addr, unsigned flags);

   struct uv_udp_s {
//   UV_HANDLE_FIELDS
//   UV_UDP_PRIVATE_FIELDS
   };

   struct uv_udp_send_s {
//   UV_REQ_FIELDS
   uv_udp_t* handle;
   uv_udp_send_cb cb;
//   UV_UDP_SEND_PRIVATE_FIELDS
   };

   struct uv_tty_s {
  // UV_HANDLE_FIELDS
  // UV_STREAM_FIELDS
   //UV_TTY_PRIVATE_FIELDS
   };

   struct uv_pipe_s {
  // UV_HANDLE_FIELDS
   //UV_STREAM_FIELDS
   //UV_PIPE_PRIVATE_FIELDS
   int ipc; /* non-zero if this pipe is used for passing handles */
   };


   struct uv_prepare_s {
  // UV_HANDLE_FIELDS
   //UV_PREPARE_PRIVATE_FIELDS
   };

   struct uv_check_s {
   //UV_HANDLE_FIELDS
   //UV_CHECK_PRIVATE_FIELDS
   };

   struct uv_idle_s {
//   UV_HANDLE_FIELDS
//   UV_IDLE_PRIVATE_FIELDS
   };

   struct uv_async_s {
  // UV_HANDLE_FIELDS
   //UV_ASYNC_PRIVATE_FIELDS
   };

   struct uv_timer_s {
   //UV_HANDLE_FIELDS
   //UV_TIMER_PRIVATE_FIELDS
   };

   uv_loop_t*     uv_default_loop(    );
   uv_loop_t*     uv_loop_new(        );
   void           uv_loop_delete(     uv_loop_t* );
   int            uv_run(             uv_loop_t* );
   int            uv_run_once(        uv_loop_t* );
   void           uv_ref(             uv_loop_t* );
   void           uv_unref(           uv_loop_t* );
   void           uv_update_time(     uv_loop_t* );
   int64_t        uv_now(             uv_loop_t* );
   uv_err_t       uv_last_error(      uv_loop_t* );

   const char*    uv_strerror(        uv_err_t err );
   const char*    uv_err_name(        uv_err_t err );
   int            uv_shutdown(        uv_shutdown_t* req, uv_stream_t* handle,  uv_shutdown_cb cb );
   int            uv_is_active(       uv_handle_t* handle );
   void           uv_close(           uv_handle_t* handle, uv_close_cb close_cb );
   uv_buf_t       uv_buf_init(        char* base, size_t len );
   size_t         uv_strlcpy(         char* dst, const char* src, size_t size );
   size_t         uv_strlcat(         char* dst, const char* src, size_t size );

   int            uv_listen(          uv_stream_t* stream, int backlog, uv_connection_cb cb );
   int            uv_accept(          uv_stream_t* server, uv_stream_t* client );

   int            uv_read_start(      uv_stream_t*, uv_alloc_cb alloc_cb, uv_read_cb read_cb );
   int            uv_read_stop(       uv_stream_t* );
   int            uv_read2_start(     uv_stream_t*, uv_alloc_cb alloc_cb, uv_read2_cb read_cb );

   int            uv_write(           uv_write_t* req, uv_stream_t* handle, uv_buf_t bufs[], int bufcnt, uv_write_cb cb );
   int            uv_write2(          uv_write_t* req, uv_stream_t* handle, uv_buf_t bufs[], int bufcnt, uv_stream_t* send_handle, uv_write_cb cb );

   int            uv_tcp_init(        uv_loop_t*, uv_tcp_t* handle );
   int            uv_tcp_nodelay(     uv_tcp_t* handle, int enable );
   int            uv_tcp_keepalive(   uv_tcp_t* handle, int enable, unsigned int delay );
   int            uv_tcp_simultaneous_accepts(      uv_tcp_t* handle, int enable );
   int            uv_tcp_bind(        uv_tcp_t* handle, struct sockaddr_in );
   int            uv_tcp_bind6(       uv_tcp_t* handle, struct sockaddr_in6 );
   int            uv_tcp_getsockname( uv_tcp_t* handle, struct sockaddr* name, int* namelen );
   int            uv_tcp_getpeername( uv_tcp_t* handle, struct sockaddr* name, int* namelen );
   int            uv_tcp_connect(     uv_connect_t* req, uv_tcp_t* handle, struct sockaddr_in  address, uv_connect_cb cb );
   int            uv_tcp_connect6(    uv_connect_t* req, uv_tcp_t* handle, struct sockaddr_in6 address, uv_connect_cb cb );

   int            uv_udp_init(        uv_loop_t*, uv_udp_t* handle );
   int            uv_udp_bind(        uv_udp_t* handle, struct sockaddr_in  addr, unsigned flags );
   int            uv_udp_bind6(       uv_udp_t* handle, struct sockaddr_in6 addr, unsigned flags );
   int            uv_udp_getsockname( uv_udp_t* handle, struct sockaddr* name, int* namelen );
   int            uv_udp_set_membership(  uv_udp_t* handle, const char* multicast_addr, const char* interface_addr, uv_membership membership );
   int            uv_udp_send(        uv_udp_send_t* req, uv_udp_t* handle, uv_buf_t bufs[], int bufcnt, struct sockaddr_in  addr, uv_udp_send_cb send_cb );
   int            uv_udp_send6(       uv_udp_send_t* req, uv_udp_t* handle, uv_buf_t bufs[], int bufcnt, struct sockaddr_in6 addr, uv_udp_send_cb send_cb );
   int            uv_udp_recv_start(  uv_udp_t* handle, uv_alloc_cb alloc_cb, uv_udp_recv_cb recv_cb );
   int            uv_udp_recv_stop(   uv_udp_t* handle );

   int            uv_tty_init(        uv_loop_t*, uv_tty_t*, uv_file fd, int readable );
   int            uv_tty_set_mode(    uv_tty_t*, int mode );
   void           uv_tty_reset_mode(  );
   int            uv_tty_get_winsize( uv_tty_t*, int* width, int* height );

   uv_handle_type uv_guess_handle(    uv_file file );

   int            uv_pipe_init(       uv_loop_t*, uv_pipe_t* handle, int ipc );
   void           uv_pipe_open(       uv_pipe_t*, uv_file file );
   int            uv_pipe_bind(       uv_pipe_t* handle, const char* name );
   void           uv_pipe_connect(    uv_connect_t* req, uv_pipe_t* handle, const char* name, uv_connect_cb cb);
   void           uv_pipe_pending_instances( uv_pipe_t* handle, int count ); 

   int            uv_prepare_init(    uv_loop_t*, uv_prepare_t* prepare );
   int            uv_prepare_start(   uv_prepare_t* prepare, uv_prepare_cb cb );
   int            uv_prepare_stop(    uv_prepare_t* prepare );

   int            uv_check_init(      uv_loop_t*, uv_check_t* check );
   int            uv_check_start(     uv_check_t* check, uv_check_cb cb );
   int            uv_check_stop(      uv_check_t* check );

   int            uv_idle_init(       uv_loop_t*, uv_idle_t* idle);
   int            uv_idle_start(      uv_idle_t* idle, uv_idle_cb cb);
   int            uv_idle_stop(       uv_idle_t* idle);

   int            uv_async_init(      uv_loop_t*, uv_async_t* async, uv_async_cb async_cb );
   int            uv_async_send(      uv_async_t* async);

   int            uv_timer_init( uv_loop_t*, uv_timer_t*  );
   int            uv_timer_start(            uv_timer_t*, uv_timer_cb, int64_t timeout, int64_t repeat );
   int            uv_timer_stop(             uv_timer_t*  );
   int            uv_timer_again(            uv_timer_t*  );
   void           uv_timer_set_repeat(       uv_timer_t*, int64_t repeat );
   int64_t        uv_timer_get_repeat(       uv_timer_t*  );


   /* c-ares integration initialize and terminate */
   int uv_ares_init_options(uv_loop_t*,
   ares_channel *channelptr, struct ares_options *options, int optmask);

   /* TODO remove the loop argument from this function? */
   void uv_ares_destroy(uv_loop_t*, ares_channel channel);


   /*
   * uv_getaddrinfo_t is a subclass of uv_req_t
   *
   * Request object for uv_getaddrinfo.
   */
   struct uv_getaddrinfo_s {
   UV_REQ_FIELDS
   /* read-only */
   uv_loop_t* loop; \
   UV_GETADDRINFO_PRIVATE_FIELDS
   };


   /*
   * Asynchronous getaddrinfo(3).
   *
   * Return code 0 means that request is accepted and callback will be called
   * with result. Other return codes mean that there will not be a callback.
   * Input arguments may be released after return from this call.
   *
   * uv_freeaddrinfo() must be called after completion to free the addrinfo
   * structure.
   *
   * On error NXDOMAIN the status code will be non-zero and UV_ENOENT returned.
   */
   int uv_getaddrinfo(uv_loop_t*, uv_getaddrinfo_t* handle,
   uv_getaddrinfo_cb getaddrinfo_cb, const char* node, const char* service,
   const struct addrinfo* hints);

   void uv_freeaddrinfo(struct addrinfo* ai);

   /* uv_spawn() options */
   typedef struct uv_process_options_s {
   uv_exit_cb exit_cb; /* Called after the process exits. */
   const char* file; /* Path to program to execute. */
   /*
   * Command line arguments. args[0] should be the path to the program. On
   * Windows this uses CreateProcess which concatenates the arguments into a
   * string this can cause some strange errors. See the note at
   * windows_verbatim_arguments.
   */
   char** args;
   /*
   * This will be set as the environ variable in the subprocess. If this is
   * NULL then the parents environ will be used.
   */
   char** env;
   /*
   * If non-null this represents a directory the subprocess should execute
   * in. Stands for current working directory.
   */
   char* cwd;

   /*
   * TODO describe how this works.
   */
   int windows_verbatim_arguments;

   /*
   * The user should supply pointers to initialized uv_pipe_t structs for
   * stdio. This is used to to send or receive input from the subprocess.
   * The user is responsible for calling uv_close on them.
   */
   uv_pipe_t* stdin_stream;
   uv_pipe_t* stdout_stream;
   uv_pipe_t* stderr_stream;
   } uv_process_options_t;

   /*
   * uv_process_t is a subclass of uv_handle_t
   */
   struct uv_process_s {
   UV_HANDLE_FIELDS
   uv_exit_cb exit_cb;
   int pid;
   UV_PROCESS_PRIVATE_FIELDS
   };

   /* Initializes uv_process_t and starts the process. */
   int uv_spawn(uv_loop_t*, uv_process_t*,
   uv_process_options_t options);

   /*
   * Kills the process with the specified signal. The user must still
   * call uv_close on the process.
   */
   int uv_process_kill(uv_process_t*, int signum);


   /* Kills the process with the specified signal. */
   uv_err_t uv_kill(int pid, int signum);


   /*
   * uv_work_t is a subclass of uv_req_t
   */
   struct uv_work_s {
   UV_REQ_FIELDS
   uv_loop_t* loop;
   uv_work_cb work_cb;
   uv_after_work_cb after_work_cb;
   UV_WORK_PRIVATE_FIELDS
   };

   /* Queues a work request to execute asynchronously on the thread pool. */
   int uv_queue_work(uv_loop_t* loop, uv_work_t* req,
   uv_work_cb work_cb, uv_after_work_cb after_work_cb);




   /*
   * File System Methods.
   *
   * The uv_fs_* functions execute a blocking system call asynchronously (in a
   * thread pool) and call the specified callback in the specified loop after
   * completion. If the user gives NULL as the callback the blocking system
   * call will be called synchronously. req should be a pointer to an
   * uninitialized uv_fs_t object.
   *
   * uv_fs_req_cleanup() must be called after completion of the uv_fs_
   * function to free any internal memory allocations associated with the
   * request.
   */

   typedef enum {
   UV_FS_UNKNOWN = -1,
   UV_FS_CUSTOM,
   UV_FS_OPEN,
   UV_FS_CLOSE,
   UV_FS_READ,
   UV_FS_WRITE,
   UV_FS_SENDFILE,
   UV_FS_STAT,
   UV_FS_LSTAT,
   UV_FS_FSTAT,
   UV_FS_FTRUNCATE,
   UV_FS_UTIME,
   UV_FS_FUTIME,
   UV_FS_CHMOD,
   UV_FS_FCHMOD,
   UV_FS_FSYNC,
   UV_FS_FDATASYNC,
   UV_FS_UNLINK,
   UV_FS_RMDIR,
   UV_FS_MKDIR,
   UV_FS_RENAME,
   UV_FS_READDIR,
   UV_FS_LINK,
   UV_FS_SYMLINK,
   UV_FS_READLINK,
   UV_FS_CHOWN,
   UV_FS_FCHOWN
   } uv_fs_type;

   /* uv_fs_t is a subclass of uv_req_t */
   struct uv_fs_s {
   UV_REQ_FIELDS
   uv_loop_t* loop;
   uv_fs_type fs_type;
   uv_fs_cb cb;
   ssize_t result;
   void* ptr;
   char* path;
   int errorno;
   UV_FS_PRIVATE_FIELDS
   };

   /*
   * This flag can be used with uv_fs_symlink on Windows
   * to specify whether path argument points to a directory.
   */
   #define UV_FS_SYMLINK_DIR          0x0001


   enum uv_fs_event {
   UV_RENAME = 1,
   UV_CHANGE = 2
   };


   struct uv_fs_event_s {
   UV_HANDLE_FIELDS
   char* filename;
   UV_FS_EVENT_PRIVATE_FIELDS
   };

   enum uv_fs_event_flags {
   /*
   * By default, if the fs event watcher is given a directory name, we will
   * watch for all events in that directory. This flags overrides this behavior
   * and makes fs_event report only changes to the directory entry itself. This
   * flag does not affect individual files watched.
   * This flag is currently not implemented yet on any backend.
   */
   UV_FS_EVENT_WATCH_ENTRY = 1,

   /*
   * By default uv_fs_event will try to use a kernel interface such as inotify
   * or kqueue to detect events. This may not work on remote filesystems such
   * as NFS mounts. This flag makes fs_event fall back to calling stat() on a
   * regular interval.
   * This flag is currently not implemented yet on any backend.
   */
   UV_FS_EVENT_STAT = 2
   };

   void uv_fs_req_cleanup(uv_fs_t* req);

   int uv_fs_close(uv_loop_t* loop, uv_fs_t* req, uv_file file,
   uv_fs_cb cb);

   int uv_fs_open(uv_loop_t* loop, uv_fs_t* req, const char* path,
   int flags, int mode, uv_fs_cb cb);

   int uv_fs_read(uv_loop_t* loop, uv_fs_t* req, uv_file file,
   void* buf, size_t length, off_t offset, uv_fs_cb cb);

   int uv_fs_unlink(uv_loop_t* loop, uv_fs_t* req, const char* path,
   uv_fs_cb cb);

   int uv_fs_write(uv_loop_t* loop, uv_fs_t* req, uv_file file,
   void* buf, size_t length, off_t offset, uv_fs_cb cb);

   int uv_fs_mkdir(uv_loop_t* loop, uv_fs_t* req, const char* path,
   int mode, uv_fs_cb cb);

   int uv_fs_rmdir(uv_loop_t* loop, uv_fs_t* req, const char* path,
   uv_fs_cb cb);

   int uv_fs_readdir(uv_loop_t* loop, uv_fs_t* req,
   const char* path, int flags, uv_fs_cb cb);

   int      uv_fs_stat(       uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb );
   int      uv_fs_fstat(      uv_loop_t* loop, uv_fs_t* req, uv_file file, uv_fs_cb cb );
   int      uv_fs_rename(     uv_loop_t* loop, uv_fs_t* req, const char* path, const char* new_path, uv_fs_cb cb);
   int      uv_fs_fsync(      uv_loop_t* loop, uv_fs_t* req, uv_file file, uv_fs_cb cb );
   int      uv_fs_fdatasync(  uv_loop_t* loop, uv_fs_t* req, uv_file file,  uv_fs_cb cb);
   int      uv_fs_ftruncate(  uv_loop_t* loop, uv_fs_t* req, uv_file file, off_t offset, uv_fs_cb cb);
   int      uv_fs_sendfile(   uv_loop_t* loop, uv_fs_t* req, uv_file out_fd,  uv_file in_fd, off_t in_offset, size_t length, uv_fs_cb cb);
   int      uv_fs_chmod(      uv_loop_t* loop, uv_fs_t* req, const char* path,  int mode, uv_fs_cb cb);
   int      uv_fs_utime(      uv_loop_t* loop, uv_fs_t* req, const char* path, double atime, double mtime, uv_fs_cb cb);
   int      uv_fs_futime(     uv_loop_t* loop, uv_fs_t* req, uv_file file,  double atime, double mtime, uv_fs_cb cb);
   int      uv_fs_lstat(      uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb);
   int      uv_fs_link(       uv_loop_t* loop, uv_fs_t* req, const char* path, const char* new_path, uv_fs_cb cb);
   int      uv_fs_symlink(    uv_loop_t* loop, uv_fs_t* req, const char* path,    const char* new_path, int flags, uv_fs_cb cb);
   int      uv_fs_readlink(   uv_loop_t* loop, uv_fs_t* req, const char* path,   uv_fs_cb cb);
   int      uv_fs_fchmod(     uv_loop_t* loop, uv_fs_t* req, uv_file file,  int mode, uv_fs_cb cb);
   int      uv_fs_chown(      uv_loop_t* loop, uv_fs_t* req, const char* path,   int uid, int gid, uv_fs_cb cb);
   int      uv_fs_fchown(     uv_loop_t* loop, uv_fs_t* req, uv_file file,  int uid, int gid, uv_fs_cb cb);
   void     uv_loadavg(       double avg[3] );
   int      uv_fs_event_init( uv_loop_t* loop, uv_fs_event_t* handle, const char* filename, uv_fs_event_cb cb, int flags);

   struct sockaddr_in  uv_ip4_addr(const char* ip, int port);
   struct sockaddr_in6 uv_ip6_addr(const char* ip, int port);
   int      uv_ip4_name(struct sockaddr_in* src, char* dst, size_t size);
   int      uv_ip6_name(struct sockaddr_in6* src, char* dst, size_t size);
   int      uv_exepath(char* buffer, size_t* size);
   uv_err_t uv_cwd(char* buffer, size_t size);
   uv_err_t uv_chdir(const char* dir);
   uint64_t uv_get_free_memory(void);
   uint64_t uv_get_total_memory(void);
   uint64_t uv_hrtime(void);
   uv_err_t uv_dlopen(const char* filename, uv_lib_t* library);
   uv_err_t uv_dlclose(uv_lib_t library);
   uv_err_t uv_dlsym(uv_lib_t library, const char* name, void** ptr);
   int      uv_mutex_init(uv_mutex_t* handle);
   void     uv_mutex_destroy(uv_mutex_t* handle);
   void     uv_mutex_lock(uv_mutex_t* handle);
   int      uv_mutex_trylock(uv_mutex_t* handle);
   void     uv_mutex_unlock(uv_mutex_t* handle);
   int      uv_rwlock_init(uv_rwlock_t* rwlock);
   void     uv_rwlock_destroy(uv_rwlock_t* rwlock);
   void     uv_rwlock_rdlock(uv_rwlock_t* rwlock);
   int      uv_rwlock_tryrdlock(uv_rwlock_t* rwlock);
   void     uv_rwlock_rdunlock(uv_rwlock_t* rwlock);
   void     uv_rwlock_wrlock(uv_rwlock_t* rwlock);
   int      uv_rwlock_trywrlock(uv_rwlock_t* rwlock);
   void     uv_rwlock_wrunlock(uv_rwlock_t* rwlock);
   int      uv_thread_create(uv_thread_t *tid, void (*entry)(void *arg), void *arg);
   int      uv_thread_join(uv_thread_t *tid);

   /* the presence of these unions force similar struct layout */
   union uv_any_handle {
   uv_tcp_t tcp;
   uv_pipe_t pipe;
   uv_prepare_t prepare;
   uv_check_t check;
   uv_idle_t idle;
   uv_async_t async;
   uv_timer_t timer;
   uv_getaddrinfo_t getaddrinfo;
   uv_fs_event_t fs_event;
   };

   union uv_any_req {
   uv_req_t req;
   uv_write_t write;
   uv_connect_t connect;
   uv_shutdown_t shutdown;
   uv_fs_t fs_req;
   uv_work_t work_req;
   };


   struct uv_counters_s {
   uint64_t eio_init;
   uint64_t req_init;
   uint64_t handle_init;
   uint64_t stream_init;
   uint64_t tcp_init;
   uint64_t udp_init;
   uint64_t pipe_init;
   uint64_t tty_init;
   uint64_t prepare_init;
   uint64_t check_init;
   uint64_t idle_init;
   uint64_t async_init;
   uint64_t timer_init;
   uint64_t process_init;
   uint64_t fs_event_init;
   };


   struct uv_loop_s {
   UV_LOOP_PRIVATE_FIELDS
   /* list used for ares task handles */
   uv_ares_task_t* uv_ares_handles_;
   /* Various thing for libeio. */
   uv_async_t uv_eio_want_poll_notifier;
   uv_async_t uv_eio_done_poll_notifier;
   uv_idle_t uv_eio_poller;
   /* Diagnostic counters */
   uv_counters_t counters;
   /* The last error */
   uv_err_t last_err;
   /* User data - use this for whatever. */
   void* data;
   };
]]

return uv
