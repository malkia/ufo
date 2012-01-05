-- Contributed by Christian Schneider

local ffi = require "ffi"

local libs = ffi_ssh_libs or {
	Windows = { x86 = "bin/ssh.dll", x64 = "bin/ssh.dll" },
}

local ssh = ffi.load( ffi_ssh_lib or libs[ ffi.os ][ ffi.arch ] or "ssh" )

ffi.cdef([[
typedef int socket_t;
typedef struct mode_t_struct* mode_t;
typedef struct fd_set_struct* fd_set;
enum {
	SSH2_MSG_DISCONNECT=1,
	SSH2_MSG_IGNORE=2,
	SSH2_MSG_UNIMPLEMENTED=3,
	SSH2_MSG_DEBUG=4,
	SSH2_MSG_SERVICE_REQUEST=5,
	SSH2_MSG_SERVICE_ACCEPT=6,

	SSH2_MSG_KEXINIT=20,
	SSH2_MSG_NEWKEYS=21,

	SSH2_MSG_KEXDH_INIT=30,
	SSH2_MSG_KEXDH_REPLY=31,

	SSH2_MSG_KEX_DH_GEX_REQUEST_OLD=30,
	SSH2_MSG_KEX_DH_GEX_GROUP=31,
	SSH2_MSG_KEX_DH_GEX_INIT=32,
	SSH2_MSG_KEX_DH_GEX_REPLY=33,
	SSH2_MSG_KEX_DH_GEX_REQUEST=34,
	SSH2_MSG_USERAUTH_REQUEST=50,
	SSH2_MSG_USERAUTH_FAILURE=51,
	SSH2_MSG_USERAUTH_SUCCESS=52,
	SSH2_MSG_USERAUTH_BANNER=53,
	SSH2_MSG_USERAUTH_PK_OK=60,
	SSH2_MSG_USERAUTH_PASSWD_CHANGEREQ=60,
	SSH2_MSG_USERAUTH_INFO_REQUEST=60,
	SSH2_MSG_USERAUTH_INFO_RESPONSE=61,
	SSH2_MSG_GLOBAL_REQUEST=80,
	SSH2_MSG_REQUEST_SUCCESS=81,
	SSH2_MSG_REQUEST_FAILURE=82,
	SSH2_MSG_CHANNEL_OPEN=90,
	SSH2_MSG_CHANNEL_OPEN_CONFIRMATION=91,
	SSH2_MSG_CHANNEL_OPEN_FAILURE=92,
	SSH2_MSG_CHANNEL_WINDOW_ADJUST=93,
	SSH2_MSG_CHANNEL_DATA=94,
	SSH2_MSG_CHANNEL_EXTENDED_DATA=95,
	SSH2_MSG_CHANNEL_EOF=96,
	SSH2_MSG_CHANNEL_CLOSE=97,
	SSH2_MSG_CHANNEL_REQUEST=98,
	SSH2_MSG_CHANNEL_SUCCESS=99,
	SSH2_MSG_CHANNEL_FAILURE=100,

	SSH2_DISCONNECT_HOST_NOT_ALLOWED_TO_CONNECT=1,
	SSH2_DISCONNECT_PROTOCOL_ERROR=2,
	SSH2_DISCONNECT_KEY_EXCHANGE_FAILED=3,
	SSH2_DISCONNECT_HOST_AUTHENTICATION_FAILED=4,
	SSH2_DISCONNECT_RESERVED=4,
	SSH2_DISCONNECT_MAC_ERROR=5,
	SSH2_DISCONNECT_COMPRESSION_ERROR=6,
	SSH2_DISCONNECT_SERVICE_NOT_AVAILABLE=7,
	SSH2_DISCONNECT_PROTOCOL_VERSION_NOT_SUPPORTED=8,
	SSH2_DISCONNECT_HOST_KEY_NOT_VERIFIABLE=9,
	SSH2_DISCONNECT_CONNECTION_LOST=10,
	SSH2_DISCONNECT_BY_APPLICATION=11,
	SSH2_DISCONNECT_TOO_MANY_CONNECTIONS=12,
	SSH2_DISCONNECT_AUTH_CANCELLED_BY_USER=13,
	SSH2_DISCONNECT_NO_MORE_AUTH_METHODS_AVAILABLE=14,
	SSH2_DISCONNECT_ILLEGAL_USER_NAME=15,

	SSH2_OPEN_ADMINISTRATIVELY_PROHIBITED=1,
	SSH2_OPEN_CONNECT_FAILED=2,
	SSH2_OPEN_UNKNOWN_CHANNEL_TYPE=3,
	SSH2_OPEN_RESOURCE_SHORTAGE=4,

	SSH2_EXTENDED_DATA_STDERR=1,
};
typedef struct ssh_agent_struct* ssh_agent;
typedef struct ssh_buffer_struct* ssh_buffer;
typedef struct ssh_channel_struct* ssh_channel;
typedef struct ssh_message_struct* ssh_message;
typedef struct ssh_pcap_file_struct* ssh_pcap_file;
typedef struct ssh_private_key_struct* ssh_private_key;
typedef struct ssh_public_key_struct* ssh_public_key;
typedef struct ssh_key_struct* ssh_key;
typedef struct ssh_scp_struct* ssh_scp;
typedef struct ssh_session_struct* ssh_session;
typedef struct ssh_string_struct* ssh_string;
/* the offsets of methods */
enum ssh_kex_types_e {
	SSH_KEX=0,
	SSH_HOSTKEYS,
	SSH_CRYPT_C_S,
	SSH_CRYPT_S_C,
	SSH_MAC_C_S,
	SSH_MAC_S_C,
	SSH_COMP_C_S,
	SSH_COMP_S_C,
	SSH_LANG_C_S,
	SSH_LANG_S_C
};
enum {
	SSH_CRYPT=2,
	SSH_MAC=3,
	SSH_COMP=4,
	SSH_LANG=5
};
enum ssh_auth_e {
	SSH_AUTH_SUCCESS=0,
	SSH_AUTH_DENIED,
	SSH_AUTH_PARTIAL,
	SSH_AUTH_INFO,
	SSH_AUTH_AGAIN,
	SSH_AUTH_ERROR=-1
};

/* auth flags */
enum {
	SSH_AUTH_METHOD_UNKNOWN=0,
	SSH_AUTH_METHOD_NONE=0x0001,
	SSH_AUTH_METHOD_PASSWORD=0x0002,
	SSH_AUTH_METHOD_PUBLICKEY=0x0004,
	SSH_AUTH_METHOD_HOSTBASED=0x0008,
	SSH_AUTH_METHOD_INTERACTIVE=0x0010
};
/* messages */
enum ssh_requests_e {
	SSH_REQUEST_AUTH=1,
	SSH_REQUEST_CHANNEL_OPEN,
	SSH_REQUEST_CHANNEL,
	SSH_REQUEST_SERVICE,
	SSH_REQUEST_GLOBAL
};

enum ssh_channel_type_e {
	SSH_CHANNEL_UNKNOWN=0,
	SSH_CHANNEL_SESSION,
	SSH_CHANNEL_DIRECT_TCPIP,
	SSH_CHANNEL_FORWARDED_TCPIP,
	SSH_CHANNEL_X11
};

enum ssh_channel_requests_e {
	SSH_CHANNEL_REQUEST_UNKNOWN=0,
	SSH_CHANNEL_REQUEST_PTY,
	SSH_CHANNEL_REQUEST_EXEC,
	SSH_CHANNEL_REQUEST_SHELL,
	SSH_CHANNEL_REQUEST_ENV,
	SSH_CHANNEL_REQUEST_SUBSYSTEM,
	SSH_CHANNEL_REQUEST_WINDOW_CHANGE
};

enum ssh_global_requests_e {
	SSH_GLOBAL_REQUEST_UNKNOWN=0,
	SSH_GLOBAL_REQUEST_TCPIP_FORWARD,
	SSH_GLOBAL_REQUEST_CANCEL_TCPIP_FORWARD,
};

enum ssh_publickey_state_e {
	SSH_PUBLICKEY_STATE_ERROR=-1,
	SSH_PUBLICKEY_STATE_NONE=0,
	SSH_PUBLICKEY_STATE_VALID=1,
	SSH_PUBLICKEY_STATE_WRONG=2
};

/* status flags */
enum {
	SSH_CLOSED=0x01,
	SSH_READ_PENDING=0x02,
	SSH_CLOSED_ERROR=0x04
};
enum ssh_server_known_e {
	SSH_SERVER_ERROR=-1,
	SSH_SERVER_NOT_KNOWN=0,
	SSH_SERVER_KNOWN_OK,
	SSH_SERVER_KNOWN_CHANGED,
	SSH_SERVER_FOUND_OTHER,
	SSH_SERVER_FILE_NOT_FOUND
};

enum {
    MD5_DIGEST_LEN=16
}
/* errors */

enum ssh_error_types_e {
	SSH_NO_ERROR=0,
	SSH_REQUEST_DENIED,
	SSH_FATAL,
	SSH_EINTR
};

/* some types for keys */
enum ssh_keytypes_e{
  SSH_KEYTYPE_UNKNOWN=0,
  SSH_KEYTYPE_DSS=1,
  SSH_KEYTYPE_RSA,
  SSH_KEYTYPE_RSA1
};

/* Error return codes */
enum {
	SSH_OK=0,     /* No error */
	SSH_ERROR=-1, /* Error of some kind */
	SSH_AGAIN=-2, /* The nonblocking call must be repeated */
	SSH_EOF=-127 /* We have already a eof */
};

/**
 * @addtogroup libssh_log
 *
 * @{
 */

/**
 * @brief Verbosity level for logging and help to debugging
 */
enum {
	/** No logging at all
	 */
	SSH_LOG_NOLOG=0,
	/** Only rare and noteworthy events
	 */
	SSH_LOG_RARE,
	/** High level protocol information
	 */
	SSH_LOG_PROTOCOL,
	/** Lower level protocol infomations, packet level
	 */
	SSH_LOG_PACKET,
	/** Every function path
	 */
	SSH_LOG_FUNCTIONS
};
/** @} */

enum ssh_options_e {
  SSH_OPTIONS_HOST,
  SSH_OPTIONS_PORT,
  SSH_OPTIONS_PORT_STR,
  SSH_OPTIONS_FD,
  SSH_OPTIONS_USER,
  SSH_OPTIONS_SSH_DIR,
  SSH_OPTIONS_IDENTITY,
  SSH_OPTIONS_ADD_IDENTITY,
  SSH_OPTIONS_KNOWNHOSTS,
  SSH_OPTIONS_TIMEOUT,
  SSH_OPTIONS_TIMEOUT_USEC,
  SSH_OPTIONS_SSH1,
  SSH_OPTIONS_SSH2,
  SSH_OPTIONS_LOG_VERBOSITY,
  SSH_OPTIONS_LOG_VERBOSITY_STR,
  SSH_OPTIONS_CIPHERS_C_S,
  SSH_OPTIONS_CIPHERS_S_C,
  SSH_OPTIONS_COMPRESSION_C_S,
  SSH_OPTIONS_COMPRESSION_S_C,
  SSH_OPTIONS_PROXYCOMMAND,
  SSH_OPTIONS_BINDADDR,
  SSH_OPTIONS_STRICTHOSTKEYCHECK,
  SSH_OPTIONS_COMPRESSION,
  SSH_OPTIONS_COMPRESSION_LEVEL
};

enum {
  /** Code is going to write/create remote files */
  SSH_SCP_WRITE,
  /** Code is going to read remote files */
  SSH_SCP_READ,
  SSH_SCP_RECURSIVE=0x10
};

enum ssh_scp_request_types {
  /** A new directory is going to be pulled */
  SSH_SCP_REQUEST_NEWDIR=1,
  /** A new file is going to be pulled */
  SSH_SCP_REQUEST_NEWFILE,
  /** End of requests */
  SSH_SCP_REQUEST_EOF,
  /** End of directory */
  SSH_SCP_REQUEST_ENDDIR,
  /** Warning received */
  SSH_SCP_REQUEST_WARNING
};

/*LIBSSH_API*/ int ssh_blocking_flush(ssh_session session, int timeout);
/*LIBSSH_API*/ ssh_channel ssh_channel_accept_x11(ssh_channel channel, int timeout_ms);
/*LIBSSH_API*/ int ssh_channel_change_pty_size(ssh_channel channel,int cols,int rows);
/*LIBSSH_API*/ int ssh_channel_close(ssh_channel channel);
/*LIBSSH_API*/ void ssh_channel_free(ssh_channel channel);
/*LIBSSH_API*/ int ssh_channel_get_exit_status(ssh_channel channel);
/*LIBSSH_API*/ ssh_session ssh_channel_get_session(ssh_channel channel);
/*LIBSSH_API*/ int ssh_channel_is_closed(ssh_channel channel);
/*LIBSSH_API*/ int ssh_channel_is_eof(ssh_channel channel);
/*LIBSSH_API*/ int ssh_channel_is_open(ssh_channel channel);
/*LIBSSH_API*/ ssh_channel ssh_channel_new(ssh_session session);
/*LIBSSH_API*/ int ssh_channel_open_forward(ssh_channel channel, const char *remotehost, int remoteport, const char *sourcehost, int localport);
/*LIBSSH_API*/ int ssh_channel_open_session(ssh_channel channel);
/*LIBSSH_API*/ int ssh_channel_poll(ssh_channel channel, int is_stderr);
/*LIBSSH_API*/ int ssh_channel_read(ssh_channel channel, void *dest, uint32_t count, int is_stderr);
/*LIBSSH_API*/ int ssh_channel_read_nonblocking(ssh_channel channel, void *dest, uint32_t count, int is_stderr);
/*LIBSSH_API*/ int ssh_channel_request_env(ssh_channel channel, const char *name, const char *value);
/*LIBSSH_API*/ int ssh_channel_request_exec(ssh_channel channel, const char *cmd);
/*LIBSSH_API*/ int ssh_channel_request_pty(ssh_channel channel);
/*LIBSSH_API*/ int ssh_channel_request_pty_size(ssh_channel channel, const char *term, int cols, int rows);
/*LIBSSH_API*/ int ssh_channel_request_shell(ssh_channel channel);
/*LIBSSH_API*/ int ssh_channel_request_send_signal(ssh_channel channel, const char *signum);
/*LIBSSH_API*/ int ssh_channel_request_sftp(ssh_channel channel);
/*LIBSSH_API*/ int ssh_channel_request_subsystem(ssh_channel channel, const char *subsystem);
/*LIBSSH_API*/ int ssh_channel_request_x11(ssh_channel channel, int single_connection, const char *protocol, const char *cookie, int screen_number);
/*LIBSSH_API*/ int ssh_channel_send_eof(ssh_channel channel);
/*LIBSSH_API*/ int ssh_channel_select(ssh_channel *readchans, ssh_channel *writechans, ssh_channel *exceptchans, struct timeval * timeout);
/*LIBSSH_API*/ void ssh_channel_set_blocking(ssh_channel channel, int blocking);
/*LIBSSH_API*/ int ssh_channel_write(ssh_channel channel, const void *data, uint32_t len);
/*LIBSSH_API*/ uint32_t ssh_channel_window_size(ssh_channel channel);

/*LIBSSH_API*/ int ssh_try_publickey_from_file(ssh_session session, const char *keyfile, ssh_string *publickey, int *type);

/*LIBSSH_API*/ int ssh_auth_list(ssh_session session);
/*LIBSSH_API*/ char *ssh_basename (const char *path);
/*LIBSSH_API*/ void ssh_clean_pubkey_hash(unsigned char **hash);
/*LIBSSH_API*/ int ssh_connect(ssh_session session);
/*LIBSSH_API*/ const char *ssh_copyright(void);
/*LIBSSH_API*/ void ssh_disconnect(ssh_session session);
/*LIBSSH_API*/ char *ssh_dirname (const char *path);
/*LIBSSH_API*/ int ssh_finalize(void);
/*LIBSSH_API*/ ssh_channel ssh_forward_accept(ssh_session session, int timeout_ms);
/*LIBSSH_API*/ int ssh_forward_cancel(ssh_session session, const char *address, int port);
/*LIBSSH_API*/ int ssh_forward_listen(ssh_session session, const char *address, int port, int *bound_port);
/*LIBSSH_API*/ void ssh_free(ssh_session session);
/*LIBSSH_API*/ const char *ssh_get_disconnect_message(ssh_session session);
/*LIBSSH_API*/ const char *ssh_get_error(void *error);
/*LIBSSH_API*/ int ssh_get_error_code(void *error);

/*LIBSSH_API*/ socket_t ssh_get_fd(ssh_session session);

/*LIBSSH_API*/ char *ssh_get_hexa(const unsigned char *what, size_t len);
/*LIBSSH_API*/ char *ssh_get_issue_banner(ssh_session session);
/*LIBSSH_API*/ int ssh_get_openssh_version(ssh_session session);
/*LIBSSH_API*/ ssh_string ssh_get_pubkey(ssh_session session);
/*LIBSSH_API*/ int ssh_get_pubkey_hash(ssh_session session, unsigned char **hash);
/*LIBSSH_API*/ int ssh_get_random(void *where,int len,int strong);
/*LIBSSH_API*/ int ssh_get_version(ssh_session session);
/*LIBSSH_API*/ int ssh_get_status(ssh_session session);
/*LIBSSH_API*/ int ssh_init(void);
/*LIBSSH_API*/ int ssh_is_blocking(ssh_session session);
/*LIBSSH_API*/ int ssh_is_connected(ssh_session session);
/*LIBSSH_API*/ int ssh_is_server_known(ssh_session session);

/*LIBSSH_API*/ void ssh_log(ssh_session session, int prioriry, const char *format, ...) /*PRINTF_ATTRIBUTE(3, 4)*/;

/*LIBSSH_API*/ ssh_channel ssh_message_channel_request_open_reply_accept(ssh_message msg);
/*LIBSSH_API*/ int ssh_message_channel_request_reply_success(ssh_message msg);
/*LIBSSH_API*/ void ssh_message_free(ssh_message msg);
/*LIBSSH_API*/ ssh_message ssh_message_get(ssh_session session);
/*LIBSSH_API*/ int ssh_message_subtype(ssh_message msg);
/*LIBSSH_API*/ int ssh_message_type(ssh_message msg);
/*LIBSSH_API*/ int ssh_mkdir (const char *pathname, mode_t mode);
/*LIBSSH_API*/ ssh_session ssh_new(void);

/*LIBSSH_API*/ int ssh_options_copy(ssh_session src, ssh_session *dest);
/*LIBSSH_API*/ int ssh_options_getopt(ssh_session session, int *argcptr, char **argv);
/*LIBSSH_API*/ int ssh_options_parse_config(ssh_session session, const char *filename);
/*LIBSSH_API*/ int ssh_options_set(ssh_session session, enum ssh_options_e type, const void *value);
/*LIBSSH_API*/ int ssh_pcap_file_close(ssh_pcap_file pcap);
/*LIBSSH_API*/ void ssh_pcap_file_free(ssh_pcap_file pcap);
/*LIBSSH_API*/ ssh_pcap_file ssh_pcap_file_new(void);
/*LIBSSH_API*/ int ssh_pcap_file_open(ssh_pcap_file pcap, const char *filename);

/*LIBSSH_API*/ enum ssh_keytypes_e ssh_privatekey_type(ssh_private_key privatekey);

/*LIBSSH_API*/ void ssh_print_hexa(const char *descr, const unsigned char *what, size_t len);
/*LIBSSH_API*/ int ssh_scp_accept_request(ssh_scp scp);
/*LIBSSH_API*/ int ssh_scp_close(ssh_scp scp);
/*LIBSSH_API*/ int ssh_scp_deny_request(ssh_scp scp, const char *reason);
/*LIBSSH_API*/ void ssh_scp_free(ssh_scp scp);
/*LIBSSH_API*/ int ssh_scp_init(ssh_scp scp);
/*LIBSSH_API*/ int ssh_scp_leave_directory(ssh_scp scp);
/*LIBSSH_API*/ ssh_scp ssh_scp_new(ssh_session session, int mode, const char *location);
/*LIBSSH_API*/ int ssh_scp_pull_request(ssh_scp scp);
/*LIBSSH_API*/ int ssh_scp_push_directory(ssh_scp scp, const char *dirname, int mode);
/*LIBSSH_API*/ int ssh_scp_push_file(ssh_scp scp, const char *filename, size_t size, int perms);
/*LIBSSH_API*/ int ssh_scp_read(ssh_scp scp, void *buffer, size_t size);
/*LIBSSH_API*/ const char *ssh_scp_request_get_filename(ssh_scp scp);
/*LIBSSH_API*/ int ssh_scp_request_get_permissions(ssh_scp scp);
/*LIBSSH_API*/ size_t ssh_scp_request_get_size(ssh_scp scp);
/*LIBSSH_API*/ const char *ssh_scp_request_get_warning(ssh_scp scp);
/*LIBSSH_API*/ int ssh_scp_write(ssh_scp scp, const void *buffer, size_t len);

/*LIBSSH_API*/ int ssh_select(ssh_channel *channels, ssh_channel *outchannels, socket_t maxfd, fd_set *readfds, struct timeval *timeout);

/*LIBSSH_API*/ int ssh_service_request(ssh_session session, const char *service);
/*LIBSSH_API*/ void ssh_set_blocking(ssh_session session, int blocking);
/*LIBSSH_API*/ void ssh_set_fd_except(ssh_session session);
/*LIBSSH_API*/ void ssh_set_fd_toread(ssh_session session);
/*LIBSSH_API*/ void ssh_set_fd_towrite(ssh_session session);
/*LIBSSH_API*/ void ssh_silent_disconnect(ssh_session session);
/*LIBSSH_API*/ int ssh_set_pcap_file(ssh_session session, ssh_pcap_file pcapfile);

]] .. (ffi.os ~= "Windows" and [[
	/*LIBSSH_API*/ int ssh_userauth_agent_pubkey(ssh_session session, const char *username, ssh_public_key publickey);
]] or "") .. [[

/*LIBSSH_API*/ int ssh_userauth_autopubkey(ssh_session session, const char *passphrase);
/*LIBSSH_API*/ int ssh_userauth_kbdint(ssh_session session, const char *user, const char *submethods);
/*LIBSSH_API*/ const char *ssh_userauth_kbdint_getinstruction(ssh_session session);
/*LIBSSH_API*/ const char *ssh_userauth_kbdint_getname(ssh_session session);
/*LIBSSH_API*/ int ssh_userauth_kbdint_getnprompts(ssh_session session);
/*LIBSSH_API*/ const char *ssh_userauth_kbdint_getprompt(ssh_session session, unsigned int i, char *echo);
/*LIBSSH_API*/ int ssh_userauth_kbdint_setanswer(ssh_session session, unsigned int i, const char *answer);
/*LIBSSH_API*/ int ssh_userauth_list(ssh_session session, const char *username);
/*LIBSSH_API*/ int ssh_userauth_none(ssh_session session, const char *username);
/*LIBSSH_API*/ int ssh_userauth_offer_pubkey(ssh_session session, const char *username, int type, ssh_string publickey);
/*LIBSSH_API*/ int ssh_userauth_password(ssh_session session, const char *username, const char *password);
/*LIBSSH_API*/ int ssh_userauth_pubkey(ssh_session session, const char *username, ssh_string publickey, ssh_private_key privatekey);
/*LIBSSH_API*/ int ssh_userauth_privatekey_file(ssh_session session, const char *username, const char *filename, const char *passphrase);
/*LIBSSH_API*/ const char *ssh_version(int req_version);
/*LIBSSH_API*/ int ssh_write_knownhost(ssh_session session);

/*LIBSSH_API*/ void ssh_string_burn(ssh_string str);
/*LIBSSH_API*/ ssh_string ssh_string_copy(ssh_string str);
/*LIBSSH_API*/ void *ssh_string_data(ssh_string str);
/*LIBSSH_API*/ int ssh_string_fill(ssh_string str, const void *data, size_t len);
/*LIBSSH_API*/ void ssh_string_free(ssh_string str);
/*LIBSSH_API*/ ssh_string ssh_string_from_char(const char *what);
/*LIBSSH_API*/ size_t ssh_string_len(ssh_string str);
/*LIBSSH_API*/ ssh_string ssh_string_new(size_t size);
/*LIBSSH_API*/ char *ssh_string_to_char(ssh_string str);
/*LIBSSH_API*/ void ssh_string_free_char(char *s);

/*LIBSSH_API*/ int ssh_getpass(const char *prompt, char *buf, size_t len, int echo, int verify);

]] .. (jit.version_num > 20000 and ffi_ssh_callbacks ~= false and [[

/*
#define ssh_callbacks_init(p) do { (p)->size=sizeof(*(p)); } while(0);
#define ssh_callbacks_exists(p,c) ( (p != NULL) && ( (char *)&((p)-> c) < (char *)(p) + (p)->size ) && ((p)-> c != NULL) )
#define SSH_PACKET_CALLBACK(name) int name (ssh_session session, uint8_t type, ssh_buffer packet, void *user)
*/

typedef void (*ssh_callback_int) (int code, void *user);
typedef int (*ssh_callback_data) (const void *data, size_t len, void *user);
typedef void (*ssh_callback_int_int) (int code, int errno_code, void *user);
typedef int (*ssh_message_callback) (ssh_session, ssh_message message, void *user);
typedef int (*ssh_channel_callback_int) (ssh_channel channel, int code, void *user);
typedef int (*ssh_channel_callback_data) (ssh_channel channel, int code, void *data, size_t len, void *user);
typedef int (*ssh_auth_callback) (const char *prompt, char *buf, size_t len, int echo, int verify, void *userdata);
typedef void (*ssh_log_callback) (ssh_session session, int priority, const char *message, void *userdata);
typedef void (*ssh_status_callback) (ssh_session session, float status, void *userdata);
typedef void (*ssh_global_request_callback) (ssh_session session, ssh_message message, void *userdata);
struct ssh_callbacks_struct {
  size_t size;
  void *userdata;
  ssh_auth_callback auth_function;
  ssh_log_callback log_function;
  void (*connect_status_function)(void *userdata, float status);
  ssh_global_request_callback global_request_function;
};
typedef struct ssh_callbacks_struct *ssh_callbacks;
struct ssh_socket_callbacks_struct {
  void *userdata;
  ssh_callback_data data;
  ssh_callback_int controlflow;
  ssh_callback_int_int exception;
  ssh_callback_int_int connected;
};
typedef struct ssh_socket_callbacks_struct *ssh_socket_callbacks;
enum {
	SSH_SOCKET_FLOW_WRITEWILLBLOCK=1,
	SSH_SOCKET_FLOW_WRITEWONTBLOCK=2,

	SSH_SOCKET_EXCEPTION_EOF=1,
	SSH_SOCKET_EXCEPTION_ERROR=2,

	SSH_SOCKET_CONNECTED_OK=1,
	SSH_SOCKET_CONNECTED_ERROR=2,
	SSH_SOCKET_CONNECTED_TIMEOUT=3,
};
typedef int (*ssh_packet_callback) (ssh_session session, uint8_t type, ssh_buffer packet, void *user);
enum {
	SSH_PACKET_USED=1
	SSH_PACKET_NOT_USED=2
};
struct ssh_packet_callbacks_struct {
	uint8_t start;
	uint8_t n_callbacks;
	ssh_packet_callback *callbacks;
	void *user;
};
typedef struct ssh_packet_callbacks_struct *ssh_packet_callbacks;
/*LIBSSH_API*/ int ssh_set_callbacks(ssh_session session, ssh_callbacks cb);
typedef int (*ssh_channel_data_callback) (ssh_session session, ssh_channel channel, void *data, uint32_t len, int is_stderr, void *userdata);
typedef void (*ssh_channel_eof_callback) (ssh_session session, ssh_channel channel, void *userdata);
typedef void (*ssh_channel_close_callback) (ssh_session session, ssh_channel channel, void *userdata);
typedef void (*ssh_channel_signal_callback) (ssh_session session, ssh_channel channel, const char *signal, void *userdata);
typedef void (*ssh_channel_exit_status_callback) (ssh_session session, ssh_channel channel, int exit_status, void *userdata);
typedef void (*ssh_channel_exit_signal_callback) (ssh_session session, ssh_channel channel, const char *signal, int core, const char *errmsg, const char *lang, void *userdata);
struct ssh_channel_callbacks_struct {
  size_t size;
  void *userdata;
  ssh_channel_data_callback channel_data_function;
  ssh_channel_eof_callback channel_eof_function;
  ssh_channel_close_callback channel_close_function;
  ssh_channel_signal_callback channel_signal_function;
  ssh_channel_exit_status_callback channel_exit_status_function;
  ssh_channel_exit_signal_callback channel_exit_signal_function;
};
typedef struct ssh_channel_callbacks_struct *ssh_channel_callbacks;
/*LIBSSH_API*/ int ssh_set_channel_callbacks(ssh_channel channel, ssh_channel_callbacks cb);
typedef int (*ssh_thread_callback) (void **lock);
typedef unsigned long (*ssh_thread_id_callback) (void);
struct ssh_threads_callbacks_struct {
  const char *type;
  ssh_thread_callback mutex_init;
  ssh_thread_callback mutex_destroy;
  ssh_thread_callback mutex_lock;
  ssh_thread_callback mutex_unlock;
  ssh_thread_id_callback thread_id;
};
/*LIBSSH_API*/ int ssh_threads_set_callbacks(struct ssh_threads_callbacks_struct *cb);
/*LIBSSH_API*/ struct ssh_threads_callbacks_struct *ssh_threads_get_pthread(void);
/*LIBSSH_API*/ struct ssh_threads_callbacks_struct *ssh_threads_get_noop(void);

]] or "") .. (ffi_ssh_sftp ~= false and [[

typedef uint32_t uid_t;
typedef uint32_t gid_t;
typedef ptrdiff_t ssize_t;

typedef struct sftp_attributes_struct* sftp_attributes;
typedef struct sftp_client_message_struct* sftp_client_message;
typedef struct sftp_dir_struct* sftp_dir;
typedef struct sftp_ext_struct *sftp_ext;
typedef struct sftp_file_struct* sftp_file;
typedef struct sftp_message_struct* sftp_message;
typedef struct sftp_packet_struct* sftp_packet;
typedef struct sftp_request_queue_struct* sftp_request_queue;
typedef struct sftp_session_struct* sftp_session;
typedef struct sftp_status_message_struct* sftp_status_message;
typedef struct sftp_statvfs_struct* sftp_statvfs_t;

struct sftp_session_struct {
    ssh_session session;
    ssh_channel channel;
    int server_version;
    int client_version;
    int version;
    sftp_request_queue queue;
    uint32_t id_counter;
    int errnum;
    void **handles;
    sftp_ext ext;
};

struct sftp_packet_struct {
    sftp_session sftp;
    uint8_t type;
    ssh_buffer payload;
};

/* file handler */
struct sftp_file_struct {
    sftp_session sftp;
    char *name;
    uint64_t offset;
    ssh_string handle;
    int eof;
    int nonblocking;
};

struct sftp_dir_struct {
    sftp_session sftp;
    char *name;
    ssh_string handle; /* handle to directory */
    ssh_buffer buffer; /* contains raw attributes from server which haven't been parsed */
    uint32_t count; /* counts the number of following attributes structures into buffer */
    int eof; /* end of directory listing */
};

struct sftp_message_struct {
    sftp_session sftp;
    uint8_t packet_type;
    ssh_buffer payload;
    uint32_t id;
};

/* this is a bunch of all data that could be into a message */
struct sftp_client_message_struct {
    sftp_session sftp;
    uint8_t type;
    uint32_t id;
    char *filename; /* can be "path" */
    uint32_t flags;
    sftp_attributes attr;
    ssh_string handle;
    uint64_t offset;
    uint32_t len;
    int attr_num;
    ssh_buffer attrbuf; /* used by sftp_reply_attrs */
    ssh_string data; /* can be newpath of rename() */
};

struct sftp_request_queue_struct {
    sftp_request_queue next;
    sftp_message message;
};

/* SSH_FXP_MESSAGE described into .7 page 26 */
struct sftp_status_message_struct {
    uint32_t id;
    uint32_t status;
    ssh_string error;
    ssh_string lang;
    char *errormsg;
    char *langmsg;
};

struct sftp_attributes_struct {
    char *name;
    char *longname; /* ls -l output on openssh, not reliable else */
    uint32_t flags;
    uint8_t type;
    uint64_t size;
    uint32_t uid;
    uint32_t gid;
    char *owner; /* set if openssh and version 4 */
    char *group; /* set if openssh and version 4 */
    uint32_t permissions;
    uint64_t atime64;
    uint32_t atime;
    uint32_t atime_nseconds;
    uint64_t createtime;
    uint32_t createtime_nseconds;
    uint64_t mtime64;
    uint32_t mtime;
    uint32_t mtime_nseconds;
    ssh_string acl;
    uint32_t extended_count;
    ssh_string extended_type;
    ssh_string extended_data;
};

struct sftp_statvfs_struct {
  uint64_t f_bsize; /* file system block size */
  uint64_t f_frsize; /* fundamental fs block size */
  uint64_t f_blocks; /* number of blocks (unit f_frsize) */
  uint64_t f_bfree; /* free blocks in file system */
  uint64_t f_bavail; /* free blocks for non-root */
  uint64_t f_files; /* total file inodes */
  uint64_t f_ffree; /* free file inodes */
  uint64_t f_favail; /* free file inodes for to non-root */
  uint64_t f_fsid; /* file system id */
  uint64_t f_flag; /* bit mask of f_flag values */
  uint64_t f_namemax; /* maximum filename length */
};

enum {
	LIBSFTP_VERSION=3
};

/*LIBSSH_API*/ sftp_session sftp_new(ssh_session session);
/*LIBSSH_API*/ void sftp_free(sftp_session sftp);
/*LIBSSH_API*/ int sftp_init(sftp_session sftp);
/*LIBSSH_API*/ int sftp_get_error(sftp_session sftp);
/*LIBSSH_API*/ unsigned int sftp_extensions_get_count(sftp_session sftp);
/*LIBSSH_API*/ const char *sftp_extensions_get_name(sftp_session sftp, unsigned int indexn);
/*LIBSSH_API*/ const char *sftp_extensions_get_data(sftp_session sftp, unsigned int indexn);
/*LIBSSH_API*/ int sftp_extension_supported(sftp_session sftp, const char *name, const char *data);
/*LIBSSH_API*/ sftp_dir sftp_opendir(sftp_session session, const char *path);
/*LIBSSH_API*/ sftp_attributes sftp_readdir(sftp_session session, sftp_dir dir);
/*LIBSSH_API*/ int sftp_dir_eof(sftp_dir dir);
/*LIBSSH_API*/ sftp_attributes sftp_stat(sftp_session session, const char *path);
/*LIBSSH_API*/ sftp_attributes sftp_lstat(sftp_session session, const char *path);
/*LIBSSH_API*/ sftp_attributes sftp_fstat(sftp_file file);
/*LIBSSH_API*/ void sftp_attributes_free(sftp_attributes file);
/*LIBSSH_API*/ int sftp_closedir(sftp_dir dir);
/*LIBSSH_API*/ int sftp_close(sftp_file file);
/*LIBSSH_API*/ sftp_file sftp_open(sftp_session session, const char *file, int accesstype, mode_t mode);
/*LIBSSH_API*/ void sftp_file_set_nonblocking(sftp_file handle);
/*LIBSSH_API*/ void sftp_file_set_blocking(sftp_file handle);
/*LIBSSH_API*/ ssize_t sftp_read(sftp_file file, void *buf, size_t count);
/*LIBSSH_API*/ int sftp_async_read_begin(sftp_file file, uint32_t len);
/*LIBSSH_API*/ int sftp_async_read(sftp_file file, void *data, uint32_t len, uint32_t id);
/*LIBSSH_API*/ ssize_t sftp_write(sftp_file file, const void *buf, size_t count);
/*LIBSSH_API*/ int sftp_seek(sftp_file file, uint32_t new_offset);
/*LIBSSH_API*/ int sftp_seek64(sftp_file file, uint64_t new_offset);
/*LIBSSH_API*/ unsigned long sftp_tell(sftp_file file);
/*LIBSSH_API*/ uint64_t sftp_tell64(sftp_file file);
/*LIBSSH_API*/ void sftp_rewind(sftp_file file);
/*LIBSSH_API*/ int sftp_unlink(sftp_session sftp, const char *file);
/*LIBSSH_API*/ int sftp_rmdir(sftp_session sftp, const char *directory);
/*LIBSSH_API*/ int sftp_mkdir(sftp_session sftp, const char *directory, mode_t mode);
/*LIBSSH_API*/ int sftp_rename(sftp_session sftp, const char *original, const  char *newname);
/*LIBSSH_API*/ int sftp_setstat(sftp_session sftp, const char *file, sftp_attributes attr);
/*LIBSSH_API*/ int sftp_chown(sftp_session sftp, const char *file, uid_t owner, gid_t group);
/*LIBSSH_API*/ int sftp_chmod(sftp_session sftp, const char *file, mode_t mode);
/*LIBSSH_API*/ int sftp_utimes(sftp_session sftp, const char *file, const struct timeval *times);
/*LIBSSH_API*/ int sftp_symlink(sftp_session sftp, const char *target, const char *dest);
/*LIBSSH_API*/ char *sftp_readlink(sftp_session sftp, const char *path);
/*LIBSSH_API*/ sftp_statvfs_t sftp_statvfs(sftp_session sftp, const char *path);
/*LIBSSH_API*/ sftp_statvfs_t sftp_fstatvfs(sftp_file file);
/*LIBSSH_API*/ void sftp_statvfs_free(sftp_statvfs_t statvfs_o);
/*LIBSSH_API*/ char *sftp_canonicalize_path(sftp_session sftp, const char *path);
/*LIBSSH_API*/ int sftp_server_version(sftp_session sftp);

/* this is not a public interface */
enum {
	SFTP_HANDLES=256
};
sftp_packet sftp_packet_read(sftp_session sftp);
int sftp_packet_write(sftp_session sftp,uint8_t type, ssh_buffer payload);
void sftp_packet_free(sftp_packet packet);
int buffer_add_attributes(ssh_buffer buffer, sftp_attributes attr);
sftp_attributes sftp_parse_attr(sftp_session session, ssh_buffer buf,int expectname);
/* sftpserver.c */

sftp_client_message sftp_get_client_message(sftp_session sftp);
void sftp_client_message_free(sftp_client_message msg);
int sftp_reply_name(sftp_client_message msg, const char *name, sftp_attributes attr);
int sftp_reply_handle(sftp_client_message msg, ssh_string handle);
ssh_string sftp_handle_alloc(sftp_session sftp, void *info);
int sftp_reply_attr(sftp_client_message msg, sftp_attributes attr);
void *sftp_handle(sftp_session sftp, ssh_string handle);
int sftp_reply_status(sftp_client_message msg, uint32_t status, const char *message);
int sftp_reply_names_add(sftp_client_message msg, const char *file, const char *longname, sftp_attributes attr);
int sftp_reply_names(sftp_client_message msg);
int sftp_reply_data(sftp_client_message msg, const void *data, int len);
void sftp_handle_remove(sftp_session sftp, void *handle);

/* SFTP commands and constants */
enum {
	SSH_FXP_INIT=1,
	SSH_FXP_VERSION=2,
	SSH_FXP_OPEN=3,
	SSH_FXP_CLOSE=4,
	SSH_FXP_READ=5,
	SSH_FXP_WRITE=6,
	SSH_FXP_LSTAT=7,
	SSH_FXP_FSTAT=8,
	SSH_FXP_SETSTAT=9,
	SSH_FXP_FSETSTAT=10,
	SSH_FXP_OPENDIR=11,
	SSH_FXP_READDIR=12,
	SSH_FXP_REMOVE=13,
	SSH_FXP_MKDIR=14,
	SSH_FXP_RMDIR=15,
	SSH_FXP_REALPATH=16,
	SSH_FXP_STAT=17,
	SSH_FXP_RENAME=18,
	SSH_FXP_READLINK=19,
	SSH_FXP_SYMLINK=20,

	SSH_FXP_STATUS=101,
	SSH_FXP_HANDLE=102,
	SSH_FXP_DATA=103,
	SSH_FXP_NAME=104,
	SSH_FXP_ATTRS=105,

	SSH_FXP_EXTENDED=200,
	SSH_FXP_EXTENDED_REPLY=201,

	/* attributes */
	/* sftp draft is completely braindead : version 3 and 4 have different flags for same constants */
	/* and even worst, version 4 has same flag for 2 different constants */
	/* follow up : i won't develop any sftp4 compliant library before having a clarification */

	SSH_FILEXFER_ATTR_SIZE=0x00000001,
	SSH_FILEXFER_ATTR_PERMISSIONS=0x00000004,
	SSH_FILEXFER_ATTR_ACCESSTIME=0x00000008,
	SSH_FILEXFER_ATTR_ACMODTIME=0x00000008,
	SSH_FILEXFER_ATTR_CREATETIME=0x00000010,
	SSH_FILEXFER_ATTR_MODIFYTIME=0x00000020,
	SSH_FILEXFER_ATTR_ACL=0x00000040,
	SSH_FILEXFER_ATTR_OWNERGROUP=0x00000080,
	SSH_FILEXFER_ATTR_SUBSECOND_TIMES=0x00000100,
	SSH_FILEXFER_ATTR_EXTENDED=0x80000000,
	SSH_FILEXFER_ATTR_UIDGID=0x00000002,

	/* types */
	SSH_FILEXFER_TYPE_REGULAR=1,
	SSH_FILEXFER_TYPE_DIRECTORY=2,
	SSH_FILEXFER_TYPE_SYMLINK=3,
	SSH_FILEXFER_TYPE_SPECIAL=4,
	SSH_FILEXFER_TYPE_UNKNOWN=5,

	/* Server responses */

	SSH_FX_OK=0,                   /** No error */
	SSH_FX_EOF=1,                  /** End-of-file encountered */
	SSH_FX_NO_SUCH_FILE=2,         /** File doesn't exist */
	SSH_FX_PERMISSION_DENIED=3,    /** Permission denied */
	SSH_FX_FAILURE=4,              /** Generic failure */
	SSH_FX_BAD_MESSAGE=5,          /** Garbage received from server */
	SSH_FX_NO_CONNECTION=6,        /** No connection has been set up */
	SSH_FX_CONNECTION_LOST=7,      /** There was a connection, but we lost it */
	SSH_FX_OP_UNSUPPORTED=8,       /** Operation not supported by the server */
	SSH_FX_INVALID_HANDLE=9,       /** Invalid file handle */
	SSH_FX_NO_SUCH_PATH=10,        /** No such file or directory path exists */
	SSH_FX_FILE_ALREADY_EXISTS=11, /** An attempt to create an already existing file or directory has been made */
	SSH_FX_WRITE_PROTECT=12,       /** We are trying to write on a write-protected filesystem */
	SSH_FX_NO_MEDIA=13,            /** No media in remote drive */

	/* file flags */
	SSH_FXF_READ=0x01,
	SSH_FXF_WRITE=0x02,
	SSH_FXF_APPEND=0x04,
	SSH_FXF_CREAT=0x08,
	SSH_FXF_TRUNC=0x10,
	SSH_FXF_EXCL=0x20,
	SSH_FXF_TEXT=0x40,

	/* rename flags */
	SSH_FXF_RENAME_OVERWRITE=0x00000001,
	SSH_FXF_RENAME_ATOMIC=0x00000002,
	SSH_FXF_RENAME_NATIVE=0x00000004,

	SFTP_OPEN=SSH_FXP_OPEN,
	SFTP_CLOSE=SSH_FXP_CLOSE,
	SFTP_READ=SSH_FXP_READ,
	SFTP_WRITE=SSH_FXP_WRITE,
	SFTP_LSTAT=SSH_FXP_LSTAT,
	SFTP_FSTAT=SSH_FXP_FSTAT,
	SFTP_SETSTAT=SSH_FXP_SETSTAT,
	SFTP_FSETSTAT=SSH_FXP_FSETSTAT,
	SFTP_OPENDIR=SSH_FXP_OPENDIR,
	SFTP_READDIR=SSH_FXP_READDIR,
	SFTP_REMOVE=SSH_FXP_REMOVE,
	SFTP_MKDIR=SSH_FXP_MKDIR,
	SFTP_RMDIR=SSH_FXP_RMDIR,
	SFTP_REALPATH=SSH_FXP_REALPATH,
	SFTP_STAT=SSH_FXP_STAT,
	SFTP_RENAME=SSH_FXP_RENAME,
	SFTP_READLINK=SSH_FXP_READLINK,
	SFTP_SYMLINK=SSH_FXP_SYMLINK,

	/* openssh flags */
	SSH_FXE_STATVFS_ST_RDONLY=0x1, /* read-only */
	SSH_FXE_STATVFS_ST_NOSUID=0x2, /* no setuid */
};
]] or "") .. (ffi_ssh_sftp == "server" and [[

/*LIBSSH_API*/ sftp_session sftp_server_new(ssh_session session, ssh_channel chan);
/*LIBSSH_API*/ int sftp_server_init(sftp_session sftp);

]] or ""))

return ssh