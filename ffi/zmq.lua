print( "[".. ... .. "]" )
local ffi = require( "ffi" )

local libs = ffi_zmq_libs or {
   OSX = { x86 = "bin/zmq.dylib", x64 = "bin/zmq.dylib" },
}

local lib = ffi_zmq_lib or libs[ ffi.os ][ ffi.arch ]

local zmq = ffi.load( (... and "" or "../") .. lib )

ffi.cdef [[
      enum {
	 ZMQ_VERSION_MAJOR     = 3,
	 ZMQ_VERSION_MINOR     = 0,
	 ZMQ_VERSION_PATCH     = 0,
	 ZMQ_HAUSNUMERO        = 156384712,
	 ZMQ_MAX_VSM_SIZE      = 30,
	 ZMQ_DELIMITER         = 31,
	 ZMQ_VSM               = 32,
	 ZMQ_MSG_MORE          = 1,
	 ZMQ_MSG_SHARED        = 128,

	 ZMQ_PAIR              = 0,
	 ZMQ_PUB               = 1,
	 ZMQ_SUB               = 2,
	 ZMQ_REQ               = 3,
	 ZMQ_REP               = 4,
	 ZMQ_XREQ              = 5,
	 ZMQ_XREP              = 6,
	 ZMQ_PULL              = 7,
	 ZMQ_PUSH              = 8,
	 ZMQ_XPUB              = 9,
	 ZMQ_XSUB              = 10,
	 ZMQ_UPSTREAM          = ZMQ_PULL,
	 ZMQ_DOWNSTREAM        = ZMQ_PUSH,

	 ZMQ_HWM               = 1,
	 ZMQ_SWAP              = 3,
	 ZMQ_AFFINITY          = 4,
	 ZMQ_IDENTITY          = 5,
	 ZMQ_SUBSCRIBE         = 6,
	 ZMQ_UNSUBSCRIBE       = 7,
	 ZMQ_RATE              = 8,
	 ZMQ_RECOVERY_IVL      = 9,
	 ZMQ_MCAST_LOOP        = 10,
	 ZMQ_SNDBUF            = 11,
	 ZMQ_RCVBUF            = 12,
	 ZMQ_RCVMORE           = 13,
	 ZMQ_FD                = 14,
	 ZMQ_EVENTS            = 15,
	 ZMQ_TYPE              = 16,
	 ZMQ_LINGER            = 17,
	 ZMQ_RECONNECT_IVL     = 18,
	 ZMQ_BACKLOG           = 19,
	 ZMQ_RECOVERY_IVL_MSEC = 20,
	 ZMQ_RECONNECT_IVL_MAX = 21,
    
	 ZMQ_NOBLOCK           = 1,
	 ZMQ_SNDMORE           = 2,

	 ZMQ_POLLIN            = 1,
	 ZMQ_POLLOUT           = 2, 
	 ZMQ_POLLERR           = 4,
	 
	 ZMQ_STREAMER          = 1,
	 ZMQ_FORWARDER         = 2,
	 ZMQ_QUEUE             = 3,
      }

      struct myso {
	 int x;
      }

      typedef struct {
	 void* socket;
	 int   fd;
	 short events;
	 short revents;
      } zmq_pollitem_t;

      typedef struct _zmq_msg_t {
	 void *content;
	 unsigned char flags;
	 unsigned char vsm_size;
	 unsigned char vsm_data [ZMQ_MAX_VSM_SIZE];
      } zmq_msg_t;

      typedef void (zmq_free_fn) (void *data, void *hint);

      void          zmq_version(         int* major, int* minor, int* patch );

      int           zmq_errno(           void );
      const char*   zmq_strerror(        int errnum );

      int           zmq_msg_init(        zmq_msg_t* msg );
      int           zmq_msg_init_size(   zmq_msg_t* msg, size_t size );
      int           zmq_msg_init_data(   zmq_msg_t* msg, void* data, size_t size, zmq_free_fn*, void* hint );
      int           zmq_msg_close(       zmq_msg_t* msg );
      int           zmq_msg_move(        zmq_msg_t* dest, zmq_msg_t* src );
      int           zmq_msg_copy(        zmq_msg_t* dest, zmq_msg_t* src );
      void*         zmq_msg_data(        zmq_msg_t* msg );
      size_t        zmq_msg_size(        zmq_msg_t* msg );

      void*         zmq_init(            int io_threads );
      int           zmq_term(            void* context );

      void*         zmq_socket(          void *context, int type );
      int           zmq_close(           void *s  );
      int           zmq_setsockopt(      void *s, int option, const void *optval, size_t optvallen ); 
      int           zmq_getsockopt(      void *s, int option, void *optval, size_t *optvallen );
      int           zmq_bind(            void *s, const char *addr );
      int           zmq_connect(         void *s, const char *addr );
      int           zmq_send(            void *s, const void* buf, int len, int flags );
      int           zmq_recv(            void *s, void* buf, int len, int flags );
      int           zmq_sendmsg(         void *s, zmq_msg_t *msg, int len, int flags );
      int           zmq_recvmsg(         void *s, zmq_msg_t *msg, int len, int flags );

      int           zmq_poll(            zmq_pollitem_t* items, int nitems, long timeout );

      void*         zmq_stopwatch_start( void );
      unsigned long zmq_stopwatch_stop(  void *watch );

      void          zmq_sleep(           int seconds );
]]

return zmq
