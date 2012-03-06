local ffi = require( "ffi" )

local libs = ffi_zmq_libs or {
   OSX     = { x86 = "bin/OSX/zmq.dylib", x64 = "bin/OSX/zmq.dylib" },
   Windows = { x86 = "bin/Windows/x86/zmq.dll", x64 = "bin/Windows/x64/zmq.dll" },
   Linux   = { x86 = "bin/Linux/x86/zmq.so", x64 = "bin/Linux/x64/zmq.so", arm = "bin/Linux/arm/zmq.so"  },
}

local zmq = ffi.load( ffi_zmq_lib or libs[ ffi.os ][ ffi.arch ] or "zmq" )

ffi.cdef([[
   enum {
      ZMQ_VERSION_MAJOR     = 3,
      ZMQ_VERSION_MINOR     = 1,
      ZMQ_VERSION_PATCH     = 1,
      ZMQ_VERSION           = ZMQ_VERSION_MAJOR * 10000 + ZMQ_VERSION_MINOR * 100 + ZMQ_VERSION_PATCH,
      
      ZMQ_HAUSNUMERO        = 156384712,
      
      // Socket types
      ZMQ_PAIR              = 0,
      ZMQ_PUB               = 1,
      ZMQ_SUB               = 2,
      ZMQ_REQ               = 3,
      ZMQ_REP               = 4,
      ZMQ_DEALER            = 5,
      ZMQ_ROUTER            = 6,
      ZMQ_PULL              = 7,
      ZMQ_PUSH              = 8,
      ZMQ_XPUB              = 9,
      ZMQ_XSUB              = 10,

      // Socket options
      ZMQ_AFFINITY          = 4,
      ZMQ_SUBSCRIBE         = 6,
      ZMQ_UNSUBSCRIBE       = 7,
      ZMQ_RATE              = 8,
      ZMQ_RECOVERY_IVL      = 9,
      ZMQ_SNDBUF            = 11,
      ZMQ_RCVBUF            = 12,
      ZMQ_RCVMORE           = 13,
      ZMQ_FD                = 14,
      ZMQ_EVENTS            = 15,
      ZMQ_TYPE              = 16,
      ZMQ_LINGER            = 17,
      ZMQ_RECONNECT_IVL     = 18,
      ZMQ_BACKLOG           = 19,
      ZMQ_RECONNECT_IVL_MAX = 21,
      ZMQ_MAXMSGSIZE        = 22,
      ZMQ_SNDHWM            = 23,
      ZMQ_RCVHWM            = 24,
      ZMQ_MULTICAST_HOPS    = 25,
      ZMQ_RCVTIMEO          = 27,
      ZMQ_SNDTIMEO          = 28,
      ZMQ_IPV4ONLY          = 31,
      ZMQ_LAST_ENDPOINT     = 32,

      // Message options
      ZMQ_MORE              = 1,
    
      // Send/recv options
      ZMQ_DONTWAIT          = 1,
      ZMQ_SNDMORE           = 2,

      // I/O multiplexing
      ZMQ_POLLIN            = 1,
      ZMQ_POLLOUT           = 2, 
      ZMQ_POLLERR           = 4,
   }

   typedef struct zmq_socket_t { 
      void *data;
   } zmq_socket_t;

   typedef struct zmq_ctx_t {
      void *data; 
   } zmq_ctx_t;

   typedef struct zmq_pollitem_t {
      void* socket;
]] .. ((ffi.os == "Windows") and "void*" or "int") .. [[ fd;
      short events;
      short revents;
   } zmq_pollitem_t;

   typedef struct zmq_msg_t {
      unsigned char _ [32];
   } zmq_msg_t;

   typedef struct zmq_iovec_t {
      void *iov_base;
      size_t iov_len;
   } zmq_iovec_t;


   typedef void (zmq_free_fn)(        void *data, void *hint );

   void          zmq_version(         int* major, int* minor, int* patch );

   int           zmq_errno(           void );
   const char*   zmq_strerror(        int errnum );
   
   int           zmq_msg_init(        zmq_msg_t* msg );
   int           zmq_msg_init_size(   zmq_msg_t* msg, size_t size );
   int           zmq_msg_init_data(   zmq_msg_t* msg, void* data, size_t size, zmq_free_fn*, void* hint );
   int           zmq_msg_send(        zmq_msg_t* msg, zmq_socket_t s, int flags );
   int           zmq_msg_recv(        zmq_msg_t* msg, zmq_socket_t s, int flags );
   int           zmq_msg_close(       zmq_msg_t* msg );
   int           zmq_msg_move(        zmq_msg_t* dest, zmq_msg_t* src );
   int           zmq_msg_copy(        zmq_msg_t* dest, zmq_msg_t* src );
   void*         zmq_msg_data(        zmq_msg_t* msg );
   size_t        zmq_msg_size(        zmq_msg_t* msg );
   int           zmq_msg_more(        zmq_msg_t* msg );
   int           zmq_msg_get(         zmq_msg_t* msg, int option,       void *optval, size_t* optvallen );
   int           zmq_msg_set(         zmq_msg_t *msg, int option, const void *optval, size_t* optvallen);

   zmq_ctx_t     zmq_init(            int io_threads );
   int           zmq_term(            zmq_ctx_t context );
   
   zmq_socket_t  zmq_socket(          zmq_ctx_t, int type );
   int           zmq_close(           zmq_socket_t );
   int           zmq_setsockopt(      zmq_socket_t, int option, const void *optval, size_t  optvallen ); 
   int           zmq_getsockopt(      zmq_socket_t, int option,       void *optval, size_t* optvallen );
   int           zmq_bind(            zmq_socket_t, const char *addr );
   int           zmq_connect(         zmq_socket_t, const char *addr );
   int           zmq_send(            zmq_socket_t, const void* buf, int len, int flags );
   int           zmq_recv(            zmq_socket_t,       void* buf, int len, int flags );
   int           zmq_sendmsg(         zmq_socket_t, zmq_msg_t* msg, int flags );
   int           zmq_recvmsg(         zmq_socket_t, zmq_msg_t* msg, int flags );
   int           zmq_sendiov(         zmq_socket_t, zmq_iovec_t* iov, size_t  count, int flags );
   int           zmq_recviov(         zmq_socket_t, zmq_iovec_t* iov, size_t *count, int flags );
   
   int           zmq_poll(            zmq_pollitem_t* items, int nitems, long timeout );

   void*         zmq_stopwatch_start( void );
   unsigned long zmq_stopwatch_stop(  void *watch );
   
   void          zmq_sleep(           int seconds );
]])

return zmq
