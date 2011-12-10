enum {
   ARES_VERSION_MAJOR = 1,
   ARES_VERSION_MINOR = 7,
   ARES_VERSION_PATCH = 5,
   ARES_VERSION = (ARES_VERSION_MAJOR<<16) | (ARES_VERSION_MINOR<<8) | (ARES_VERSION_PATCH)
   // ARES_COPYRIGHT = "2004 - 2010 Daniel Stenberg, <daniel@haxx.se>."
   // ARES_VERSION_STR = "1.7.5-DEV"

   ARES_SUCCESS            0
   ARES_ENODATA            1
   ARES_EFORMERR           2
   ARES_ESERVFAIL          3
   ARES_ENOTFOUND          4
   ARES_ENOTIMP            5
   ARES_EREFUSED           6
   ARES_EBADQUERY          7
   ARES_EBADNAME           8
   ARES_EBADFAMILY         9
   ARES_EBADRESP           10
   ARES_ECONNREFUSED       11
   ARES_ETIMEOUT           12
   ARES_EOF                13
   ARES_EFILE              14
   ARES_ENOMEM             15
   ARES_EDESTRUCTION       16
   ARES_EBADSTR            17
   ARES_EBADFLAGS          18
   ARES_ENONAME            19
   ARES_EBADHINTS          20
   ARES_ENOTINITIALIZED    21          /* introduced in 1.7.0 */
   ARES_ELOADIPHLPAPI           22     /* introduced in 1.7.0 */
   ARES_EADDRGETNETWORKPARAMS   23     /* introduced in 1.7.0 */
   ARES_ECANCELLED         24          /* introduced in 1.7.0 */
   ARES_FLAG_USEVC         (1 << 0)
   ARES_FLAG_PRIMARY       (1 << 1)
   ARES_FLAG_IGNTC         (1 << 2)
   ARES_FLAG_NORECURSE     (1 << 3)
   ARES_FLAG_STAYOPEN      (1 << 4)
   ARES_FLAG_NOSEARCH      (1 << 5)
   ARES_FLAG_NOALIASES     (1 << 6)
   ARES_FLAG_NOCHECKRESP   (1 << 7)
   ARES_OPT_FLAGS          (1 << 0)
   ARES_OPT_TIMEOUT        (1 << 1)
   ARES_OPT_TRIES          (1 << 2)
   ARES_OPT_NDOTS          (1 << 3)
   ARES_OPT_UDP_PORT       (1 << 4)
   ARES_OPT_TCP_PORT       (1 << 5)
   ARES_OPT_SERVERS        (1 << 6)
   ARES_OPT_DOMAINS        (1 << 7)
   ARES_OPT_LOOKUPS        (1 << 8)
   ARES_OPT_SOCK_STATE_CB  (1 << 9)
   ARES_OPT_SORTLIST       (1 << 10)
   ARES_OPT_SOCK_SNDBUF    (1 << 11)
   ARES_OPT_SOCK_RCVBUF    (1 << 12)
   ARES_OPT_TIMEOUTMS      (1 << 13)
   ARES_OPT_ROTATE         (1 << 14)
   ARES_NI_NOFQDN                  (1 << 0)
   ARES_NI_NUMERICHOST             (1 << 1)
   ARES_NI_NAMEREQD                (1 << 2)
   ARES_NI_NUMERICSERV             (1 << 3)
   ARES_NI_DGRAM                   (1 << 4)
   ARES_NI_TCP                     0
   ARES_NI_UDP                     ARES_NI_DGRAM
   ARES_NI_SCTP                    (1 << 5)
   ARES_NI_DCCP                    (1 << 6)
   ARES_NI_NUMERICSCOPE            (1 << 7)
   ARES_NI_LOOKUPHOST              (1 << 8)
   ARES_NI_LOOKUPSERVICE           (1 << 9)
   ARES_NI_IDN                     (1 << 10)
   ARES_NI_IDN_ALLOW_UNASSIGNED    (1 << 11)
   ARES_NI_IDN_USE_STD3_ASCII_RULES (1 << 12)
   ARES_AI_CANONNAME               (1 << 0)
   ARES_AI_NUMERICHOST             (1 << 1)
   ARES_AI_PASSIVE                 (1 << 2)
   ARES_AI_NUMERICSERV             (1 << 3)
   ARES_AI_V4MAPPED                (1 << 4)
   ARES_AI_ALL                     (1 << 5)
   ARES_AI_ADDRCONFIG              (1 << 6)
   ARES_AI_IDN                     (1 << 10)
   ARES_AI_IDN_ALLOW_UNASSIGNED    (1 << 11)
   ARES_AI_IDN_USE_STD3_ASCII_RULES (1 << 12)
   ARES_AI_CANONIDN                (1 << 13)

   ARES_AI_MASK (ARES_AI_CANONNAME|ARES_AI_NUMERICHOST|ARES_AI_PASSIVE| \
                     ARES_AI_NUMERICSERV|ARES_AI_V4MAPPED|ARES_AI_ALL| \
                     ARES_AI_ADDRCONFIG)
   ARES_GETSOCK_MAXNUM 16 /* ares_getsock() can return info about this
                                 many sockets */
   ARES_GETSOCK_READABLE(bits,num) (bits & (1<< (num)))
   ARES_GETSOCK_WRITABLE(bits,num) (bits & (1 << ((num) + \
                                         ARES_GETSOCK_MAXNUM)))

    ARES_LIB_INIT_NONE   (0)
    ARES_LIB_INIT_WIN32  (1 << 0)
    ARES_LIB_INIT_ALL    (ARES_LIB_INIT_WIN32)

}

/*
 * Typedef our socket type
 */

#ifndef ares_socket_typedef
#ifdef WIN32
typedef SOCKET ares_socket_t;
    ARES_SOCKET_BAD INVALID_SOCKET
#else
typedef int ares_socket_t;
    ARES_SOCKET_BAD -1
#endif
    ares_socket_typedef
#endif /* ares_socket_typedef */

typedef void (*ares_sock_state_cb)(void *data,
                                   ares_socket_t socket_fd,
                                   int readable,
                                   int writable);

struct apattern;

typedef struct ares_options {
  int flags;
  int timeout; /* in seconds or milliseconds, depending on options */
  int tries;
  int ndots;
  unsigned short udp_port;
  unsigned short tcp_port;
  int socket_send_buffer_size;
  int socket_receive_buffer_size;
  struct in_addr *servers;
  int nservers;
  char **domains;
  int ndomains;
  char *lookups;
  ares_sock_state_cb sock_state_cb;
  void *sock_state_cb_data;
  struct apattern *sortlist;
  int nsort;
} ares_options;

struct hostent;
struct timeval;
struct sockaddr;
struct ares_channeldata;

typedef struct ares_channeldata *ares_channel;
typedef void (* ares_callback             )( void *arg, int status, int timeouts, unsigned char *abuf, int alen);
typedef void (* ares_host_callback        )( void *arg, int status, int timeouts, struct hostent *hostent);
typedef void (* ares_nameinfo_callback    )( void *arg, int status, int timeouts, char *node, char *service);
typedef int  (* ares_sock_create_callback )( ares_socket_t socket_fd, int type, void *data);

struct ares_in6_addr {
  union {
    unsigned char _S6_u8[16];
  } _S6_un;
};

struct ares_addrttl {
  struct in_addr ipaddr;
  int            ttl;
};

typedef struct ares_addr6ttl {
  struct ares_in6_addr ip6addr;
  int             ttl;
} ares_addr6ttl;

typedef struct ares_srv_reply {
  struct ares_srv_reply  *next;
  char                   *host;
  unsigned short          priority;
  unsigned short          weight;
  unsigned short          port;
} ares_srv_reply;

typedef struct ares_mx_reply {
  struct ares_mx_reply   *next;
  char                   *host;
  unsigned short          priority;
} ares_mx_reply;

typedef struct {
  struct ares_txt_reply  *next;
  unsigned char          *txt;
  size_t                  length;  /* length excludes null termination */
} arex_txt_reply;

/* TODO:  Hold port here as well. */
struct ares_addr_node {
  struct ares_addr_node *next;
  int family;
  union {
    struct in_addr       addr4;
    struct ares_in6_addr addr6;
  } addr;
};

typedef struct ares_timeval {
int balh;
} ares_timeval;

int           ares_library_init(        int flags );
void          ares_library_cleanup(     );
const char*   ares_version(             int* version   );
int           ares_init(                ares_channel*  );
int           ares_init_options(        ares_channel*, ares_options* options, int  optmask );
int           ares_save_options(        ares_channel,  ares_options* options, int* optmask );
void          ares_destroy_options(                    ares_options* options );
int           ares_dup(                 ares_channel*, ares_channel src );
void          ares_destroy(             ares_channel   );
void          ares_cancel(              ares_channel   );
void          ares_set_local_ip4(       ares_channel, unsigned int local_ip );
void          ares_set_local_ip6(       ares_channel, const unsigned char* local_ip6 );
void          ares_set_local_dev(       ares_channel, const char* local_dev_name);
void          ares_set_socket_callback( ares_channel, ares_sock_create_callback callback, void *user_data );
void          ares_send(                ares_channel, const unsigned char *qbuf, int qlen, ares_callback callback, void *arg );
void          ares_query(               ares_channel, const char *name, int dnsclass, int type, ares_callback callback, void *arg );
void          ares_search(              ares_channel, const char *name, int dnsclass, int type, ares_callback callback, void *arg);
void          ares_gethostbyname(       ares_channel, const char *name, int family, ares_host_callback callback, void *arg );
int           ares_gethostbyname_file(  ares_channel, const char *name, int family, struct hostent **host );
void          ares_gethostbyaddr(       ares_channel, const void *addr, int addrlen, int family, ares_host_callback callback, void *arg);
void          ares_getnameinfo(         ares_channel, const struct sockaddr *sa, ares_socklen_t salen, int flags, ares_nameinfo_callback callback, void *arg);
int           ares_fds(                 ares_channel, fd_set *read_fds, fd_set *write_fds );
int           ares_getsock(             ares_channel, ares_socket_t *socks, int numsocks );
ares_timeval* ares_timeout(             ares_channel, ares_timeval* maxtv, ares_timeval* tv );
void          ares_process(             ares_channel, fd_set *read_fds, fd_set *write_fds );
void          ares_process_fd(          ares_channel, ares_socket_t read_fd, ares_socket_t write_fd );
int           ares_mkquery(             const char *name, int dnsclass, int type, unsigned short id, int rd, unsigned char **buf, int *buflen );
int           ares_expand_name(         const unsigned char *encoded, const unsigned char *abuf, int alen, char **s, long *enclen );
int           ares_expand_string(       const unsigned char *encoded, const unsigned char *abuf, int alen, unsigned char **s, long *enclen );
int           ares_parse_a_reply(       const unsigned char *abuf, int alen, struct hostent **host, struct ares_addrttl  *addrttls, int *naddrttls );
int           ares_parse_aaaa_reply(    const unsigned char *abuf, int alen, struct hostent **host, struct ares_addr6ttl *addrttls, int *naddrttls );
int           ares_parse_ptr_reply(     const unsigned char *abuf, int alen, const void *addr, int addrlen, int family, struct hostent **host );
int           ares_parse_ns_reply(      const unsigned char *abuf, int alen, struct hostent **host );
int           ares_parse_srv_reply(     const unsigned char* abuf, int alen, struct ares_srv_reply** srv_out );
int           ares_parse_mx_reply(      const unsigned char* abuf, int alen, struct ares_mx_reply** mx_out );
int           ares_parse_txt_reply(     const unsigned char* abuf, int alen, struct ares_txt_reply** txt_out );
void          ares_free_string(         void* str );
void          ares_free_hostent(        struct hostent* host );
void          ares_free_data(           void* dataptr );
const char*   ares_strerror(            int code );
int           ares_set_servers(         ares_channel, struct ares_addr_node *servers );
int           ares_set_servers_csv(     ares_channel, const char* servers );
int           ares_get_servers(         ares_channel, struct ares_addr_node **servers );

