local ffi = require( "ffi" )

local kd = "test"

ffi.cdef[[
      enum {
	 KDINT_MIN        = -0x7fffffff-1,
	 KDINT_MAX        =  0x7fffffff,
	 KDUINT_MAX       =  0xffffffffU,
	 KDINT64_MIN      = -0x7fffffffffffffffLL-1,
	 KDINT64_MAX      =  0x7fffffffffffffffLL,
	 KDUINT64_MAX     =  0xffffffffffffffffULL,
	 KDSSIZE_MIN      = -0x7fffffff-1,
	 KDSSIZE_MAX      =  0x7fffffff,
	 KDSIZE_MAX       =  0xffffffffU,
	 KDUINTPTR_MAX    =  0xffffffffU,
      };

      enum {
	 KD_VERSION_1_0   =    1,
      };

      typedef int32_t   KDint32;
      typedef uint32_t  KDuint32;
      typedef int64_t   KDint64;
      typedef uint64_t  KDuint64;
      typedef int16_t   KDint16;
      typedef uint16_t  KDuint16;
      typedef uintptr_t KDuintptr;
      typedef size_t    KDsize;
      typedef intptr_t  KDssize;
      typedef char      KDchar;
      typedef int8_t    KDint8;
      typedef uint8_t   KDuint8;
      typedef int       KDint;
      typedef unsigned  KDuint;
      typedef float     KDfloat32;
      typedef KDint     KDboolean;
      typedef KDint64   KDtime;
      typedef KDint64   KDust;
      typedef KDint64   KDoff;
      typedef KDuint32  KDmode;

      enum {
	 KD_OK,
	 KD_EACCES,
	 KD_EADDRINUSE,
	 KD_EADDRNOTAVAIL,
	 KD_EAFNOSUPPORT,
	 KD_EAGAIN,
	 KD_EALREADY,
	 KD_EBADF,
	 KD_EBUSY,
	 KD_ECONNREFUSED,
	 KD_ECONNRESET,
	 KD_EDEADLK,
	 KD_EDESTADDRREQ,
	 KD_EEXIST,
	 KD_EFBIG,
	 KD_EHOSTUNREACH,
	 KD_EHOST_NOT_FOUND,
	 KD_EINVAL,
	 KD_EIO,
	 KD_EILSEQ,
	 KD_EISCONN,
	 KD_EISDIR, 
	 KD_EMFILE, 
	 KD_ENAMETOOLONG, 
	 KD_ENOENT, 
	 KD_ENOMEM, 
	 KD_ENOSPC, 
	 KD_ENOSYS, 
	 KD_ENOTCONN, 
	 KD_ENO_DATA, 
	 KD_ENO_RECOVERY,
	 KD_EOPNOTSUPP,
	 KD_EOVERFLOW,
	 KD_EPERM, 
	 KD_ERANGE,
	 KD_ETIMEDOUT,
	 KD_ETRY_AGAIN,
	 KD_MISSING_38,
	 KD_ATTRIB_VENDOR,
	 KD_ATTRIB_VERSION,
	 KD_ATTRIB_PLATFORM,
	 KD_EVENT_TIMER,
	 KD_EVENT_QUIT,
	 KD_EVENT_WINDOW_CLOSE,
	 KD_EVENT_PAUSE,
	 KD_EVENT_RESUME,
	 KD_EVENT_WINDOWPROPERTY_CHANGE, 
	 KD_EVENT_ORIENTATION,
	 KD_EVENT_SOCKET_READABLE,
	 KD_EVENT_SOCKET_WRITABLE,
	 KD_EVENT_SOCKET_CONNECT_COMPLETE,
	 KD_EVENT_SOCKET_INCOMING,
	 KD_EVENT_NAME_LOOKUP_COMPLETE,
	 KD_EVENT_STATE,
	 KD_MISSING_54,
	 KD_EVENT_INPUT,
	 KD_EVENT_INPUT_POINTER,
	 KD_EVENT_INPUT_STICK,
	 KD_EVENT_WINDOW_REDRAW,
	 KD_EVENT_WINDOW_FOCUS,
	 KD_TIMER_ONESHOT,
	 KD_TIMER_PERIODIC_AVERAGE,
	 KD_TIMER_PERIODIC_MINIMUM,
	 KD_SOCK_TCP,
	 KD_SOCK_UDP,
	 KD_WINDOWPROPERTY_SIZE,
	 KD_WINDOWPROPERTY_VISIBILITY,
	 KD_WINDOWPROPERTY_FOCUS,
	 KD_WINDOWPROPERTY_CAPTION,
	 KD_AF_INET,
	 KD_EVENT_INPUT_JOG,
      };

      enum {
	 KD_THREAD_CREATE_JOINABLE,
	 KD_THREAD_CREATE_DETACHED
      };

      enum {
	 KD_IOGROUP_EVENT                 = 256,
	 KD_STATE_EVENT_USING_BATTERY     = KD_IOGROUP_EVENT + 0,
	 KD_STATE_EVENT_LOW_BATTERY       = KD_IOGROUP_EVENT + 1,

	 KD_IOGROUP_ORIENTATION           = 512,
	 KD_STATE_ORIENTATION_OVERALL     = KD_IOGROUP_ORIENTATION + 0,
	 KD_STATE_ORIENTATION_SCREEN      = KD_IOGROUP_ORIENTATION + 1,
	 KD_STATE_ORIENTATION_RENDERING   = KD_IOGROUP_ORIENTATION + 2,
	 KD_STATE_ORIENTATION_LOCKSURFACE = KD_IOGROUP_ORIENTATION + 3,

      };

      enum {
	 KD_IO_CONTROLLER_STRIDE = 64,

         KD_IOGROUP_GAMEKEYS = 0x1000,
	 KD_STATE_GAMEKEYS_AVAILABILITY,
	 KD_INPUT_GAMEKEYS_UP,
	 KD_INPUT_GAMEKEYS_LEFT,        
	 KD_INPUT_GAMEKEYS_RIGHT,       
	 KD_INPUT_GAMEKEYS_DOWN,        
	 KD_INPUT_GAMEKEYS_FIRE,        
	 KD_INPUT_GAMEKEYS_A,           
	 KD_INPUT_GAMEKEYS_B,           
	 KD_INPUT_GAMEKEYS_C,           
	 KD_INPUT_GAMEKEYS_D,           

	 KD_IOGROUP_GAMEKEYSNC = 0x1100,
	 KD_STATE_GAMEKEYSNC_AVAILABILITY,
	 KD_INPUT_GAMEKEYSNC_UP,
	 KD_INPUT_GAMEKEYSNC_LEFT,
	 KD_INPUT_GAMEKEYSNC_RIGHT,
	 KD_INPUT_GAMEKEYSNC_DOWN,
	 KD_INPUT_GAMEKEYSNC_FIRE,
	 KD_INPUT_GAMEKEYSNC_A,
	 KD_INPUT_GAMEKEYSNC_B,
	 KD_INPUT_GAMEKEYSNC_C,
	 KD_INPUT_GAMEKEYSNC_D,

	 KD_IOGROUP_PHONEKEYPAD = 0x2000,
	 KD_STATE_PHONEKEYPAD_AVAILABILITY,
	 KD_INPUT_PHONEKEYPAD_0,
	 KD_INPUT_PHONEKEYPAD_1,
	 KD_INPUT_PHONEKEYPAD_2,
	 KD_INPUT_PHONEKEYPAD_3,
	 KD_INPUT_PHONEKEYPAD_4,
	 KD_INPUT_PHONEKEYPAD_5,
	 KD_INPUT_PHONEKEYPAD_6,
	 KD_INPUT_PHONEKEYPAD_7,
	 KD_INPUT_PHONEKEYPAD_8,
	 KD_INPUT_PHONEKEYPAD_9,
	 KD_INPUT_PHONEKEYPAD_STAR,
	 KD_INPUT_PHONEKEYPAD_HASH,
	 KD_INPUT_PHONEKEYPAD_LEFTSOFT,
	 KD_INPUT_PHONEKEYPAD_RIGHTSOFT,
	 KD_STATE_PHONEKEYPAD_ORIENTATION,

	 KD_IOGROUP_VIBRATE = 0x3000,
	 KD_STATE_VIBRATE_AVAILABILITY,
	 KD_STATE_VIBRATE_MINFREQUENCY,
	 KD_STATE_VIBRATE_MAXFREQUENCY,
	 KD_OUTPUT_VIBRATE_VOLUME,
	 KD_OUTPUT_VIBRATE_FREQUENCY,

	 KD_IOGROUP_POINTER = 0x4000,
	 KD_STATE_POINTER_AVAILABILITY,
	 KD_INPUT_POINTER_X,
	 KD_INPUT_POINTER_Y,
	 KD_INPUT_POINTER_SELECT,

	 KD_IOGROUP_BACKLIGHT = 0x5000,
	 KD_STATE_BACKLIGHT_AVAILABILITY,
	 KD_OUTPUT_BACKLIGHT_FORCE,

	 KD_IOGROUP_JOGDIAL = 0x6000,
	 KD_STATE_JOGDIAL_AVAILABILITY,
	 KD_INPUT_JOGDIAL_UP,
	 KD_INPUT_JOGDIAL_LEFT,
	 KD_INPUT_JOGDIAL_RIGHT,
	 KD_INPUT_JOGDIAL_DOWN,
	 KD_INPUT_JOGDIAL_SELECT,

	 KD_IOGROUP_STICK = 0x7000,
	 KD_STATE_STICK_AVAILABILITY,
	 KD_INPUT_STICK_X,
	 KD_INPUT_STICK_Y,
	 KD_INPUT_STICK_Z,
	 KD_INPUT_STICK_BUTTON,

	 KD_IO_STICK_STRIDE = 8,

	 KD_IOGROUP_DPAD = 0x8000,
	 KD_STATE_DPAD_AVAILABILITY,
	 KD_STATE_DPAD_COPY,
	 KD_INPUT_DPAD_UP,
	 KD_INPUT_DPAD_LEFT,
	 KD_INPUT_DPAD_RIGHT,
	 KD_INPUT_DPAD_DOWN,
	 KD_INPUT_DPAD_SELECT,

	 KD_IO_DPAD_STRIDE = 8,

	 KD_IOGROUP_BUTTONS = 0x9000,
	 KD_STATE_BUTTONS_AVAILABILITY,
	 KD_INPUT_BUTTONS_0,

	 KD_IO_UNDEFINED = 0x40000000,
      };

      typedef struct KDThreadAttr  KDThreadAttr;
      typedef struct KDThread      KDThread;
      typedef struct KDThreadMutex KDThreadMutex;
      typedef struct KDThreadCond  KDThreadCond;
      typedef struct KDThreadSem   KDThreadSem;
      typedef struct KDEvent       KDEvent;
      typedef struct KDTimer       KDTimer;
      typedef struct KDDir         KDDir;
      typedef struct KDFile        KDFile;
      typedef struct KDWindow      KDWindow;
      typedef struct KDSocket      KDSocket;
      
      typedef struct KDThreadOnce {
	 void *impl;
      } KDThreadOnce;

      enum {
	 KD_EVENT_USER = 0x40000000,
      };

      enum {
	 KD_THREAD_ONCE_INIT = 0,
	 KD_INADDR_ANY = 0,
	 KD_INET_ADDRSTRLEN = 16,
	 KD_FTOSTR_MAXLEN = 16
      };

      typedef enum {
	 KD_SEEK_SET = 0, 
	 KD_SEEK_CUR = 1, 
	 KD_SEEK_END = 2
      } KDfileSeekOrigin;
      
      enum {
	 KD_ISREG_MASK = 0x8000,
	 KD_ISDIR_MASK = 0x4000,
	 KD_R_OK       = 4,
	 KD_W_OK       = 2,
	 KD_X_OK       = 1,
	 KD_EOF = -1,
      }

      typedef struct KDEventUser {
	 union {
	    KDint64 i64;
	    void *p;
	    struct {
	       KDint32 a;
	       KDint32 b;
	    } i32pair;
	 } value1;
	 union {
	    KDint64 i64;
	    struct {
	       union {
		  KDint32 i32;
		  void *p;
	       } value2;
	       union {
		  KDint32 i32;
		  void *p;
	       } value3;
	    } i32orp;
	 } value23;
      } KDEventUser;

      typedef struct KDTm {
	 KDint32 tm_sec;
	 KDint32 tm_min;
	 KDint32 tm_hour;
	 KDint32 tm_mday;
	 KDint32 tm_mon;
	 KDint32 tm_year;
	 KDint32 tm_wday;
	 KDint32 tm_yday;
      } KDTm;

      typedef struct KDDirent {
	 const KDchar *d_name;
      } KDDirent;

      typedef struct KDStat {
	 KDmode st_mode;
	 KDoff  st_size;
	 KDtime st_mtime;
      } KDStat;

      typedef struct KDSockaddr {
	 KDuint16 family;
	 union {
	    struct {
	       KDuint16 port;
	       KDuint32 address;
	    } sin;
	 } data;
      } KDSockaddr;

      typedef struct KDInAddr {
	 KDuint32 s_addr;
      } KDInAddr;
      
      typedef struct KDEventSocketReadable {
	 KDSocket *socket;
      } KDEventSocketReadable;
      
      typedef struct KDEventSocketWritable {
	 KDSocket *socket;
      } KDEventSocketWritable;
      
      typedef struct KDEventSocketConnect {
	 KDSocket *socket;
	 KDint32 error;
      } KDEventSocketConnect;
      
      typedef struct KDEventSocketIncoming {
	 KDSocket *socket;
      } KDEventSocketIncoming;
      
      typedef struct KDEventNameLookup {
	 KDint32 error;
	 KDint32 resultlen;
	 const KDSockaddr *result;
	 KDboolean more;
      } KDEventNameLookup;
      
      typedef struct KDEventState {
	 KDint32 index;
	 union {
	    KDint32 i;
	    KDint64 l;
	    KDfloat32 f;
	 } value;
      } KDEventState;
      
      typedef struct KDEventInput {
	 KDint32 index;
	 union {
	    KDint32 i;
	    KDint64 l;
	    KDfloat32 f;
	 } value;
      } KDEventInput;
      
      typedef struct KDEventInputJog {
	 KDint32 index;
	 KDint32 count;
      } KDEventInputJog;
      
      typedef struct KDEventInputPointer {
	 KDint32 index;
	 KDint32 select;
	 KDint32 x;
	 KDint32 y;
      } KDEventInputPointer;
      
      typedef struct KDEventInputStick {
	 KDint32 index;
	 KDint32 x;
	 KDint32 y;
	 KDint32 z;
      } KDEventInputStick;

      typedef struct KDEventWindowProperty {
	 KDint32 pname;
      } KDEventWindowProperty;
      
      typedef struct KDEventWindowFocus {
	 KDint32 focusstate;
      } KDEventWindowFocus;
      
      typedef struct KDEvent {
	 KDust timestamp;
	 KDint32 type;
	 void *userptr;
	 union KDEventData {
	    KDEventState state;
	    KDEventInput input;
	    KDEventInputJog inputjog;
	    KDEventInputPointer inputpointer;
	    KDEventInputStick inputstick;
	    KDEventSocketReadable socketreadable;
	    KDEventSocketWritable socketwritable;
	    KDEventSocketConnect socketconnect;
	    KDEventSocketIncoming socketincoming;
	    KDEventNameLookup namelookup;
	    KDEventWindowProperty windowproperty;
	    KDEventWindowFocus windowfocus;
	    KDEventUser user;
	 } data;
      } KDEvent;
      
      typedef void ( KDCallbackFunc )(const KDEvent *event);

      KDint          kdGetError(void);
      void           kdSetError(KDint error);

      KDint          kdQueryAttribi(KDint attribute, KDint *value);
      const KDchar*  kdQueryAttribcv(KDint attribute);
      const KDchar*  kdQueryIndexedAttribcv(KDint attribute, KDint index);

      KDThreadAttr*  kdThreadAttrCreate(void);
      KDint          kdThreadAttrFree(KDThreadAttr *attr);
      KDint          kdThreadAttrSetDetachState(KDThreadAttr *attr, KDint detachstate);
      KDint          kdThreadAttrSetStackSize(KDThreadAttr *attr, KDsize stacksize);
      KDThread*      kdThreadCreate(const KDThreadAttr *attr, void *(*start_routine)(void *), void *arg);
      void           kdThreadExit(void *retval);
      KDint          kdThreadJoin(KDThread *thread, void **retval);
      KDint          kdThreadDetach(KDThread *thread);
      KDThread*      kdThreadSelf(void);
      KDint          kdThreadOnce(KDThreadOnce *once_control, void (*init_routine)(void));
      KDThreadMutex* kdThreadMutexCreate(const void *mutexattr);
      KDint          kdThreadMutexFree(     KDThreadMutex *mutex);
      KDint          kdThreadMutexLock(     KDThreadMutex *mutex);
      KDint          kdThreadMutexUnlock(   KDThreadMutex *mutex);
      KDThreadCond*  kdThreadCondCreate(    const void *attr );
      KDint          kdThreadCondFree(      KDThreadCond* cond );
      KDint          kdThreadCondSignal(    KDThreadCond* cond );
      KDint          kdThreadCondBroadcast( KDThreadCond* cond );
      KDint          kdThreadCondWait(      KDThreadCond* cond, KDThreadMutex *mutex );
      KDThreadSem*   kdThreadSemCreate(     KDuint value );
      KDint          kdThreadSemFree(       KDThreadSem* sem );
      KDint          kdThreadSemWait(       KDThreadSem* sem );
      KDint          kdThreadSemPost(       KDThreadSem* sem );

      const KDEvent* kdWaitEvent(KDust timeout);
      void           kdSetEventUserptr(void *userptr);
      void           kdDefaultEvent(const KDEvent *event);
      KDint          kdPumpEvents(void);
      KDint          kdInstallCallback(KDCallbackFunc *func, KDint eventtype, void *eventuserptr);
      KDEvent*       kdCreateEvent(void);
      KDint          kdPostEvent(KDEvent *event);
      KDint          kdPostThreadEvent(KDEvent *event, KDThread *thread);
      void           kdFreeEvent(KDEvent *event);

      KDint          kdMain(KDint argc, const KDchar *const *argv);
      void           kdExit(KDint status);

      KDint          kdAbs(KDint i);
      KDfloat32      kdStrtof(const KDchar *s, KDchar **endptr);
      KDint          kdStrtol(const KDchar *s, KDchar **endptr, KDint base);
      KDuint         kdStrtoul(const KDchar *s, KDchar **endptr, KDint base);
      KDssize        kdLtostr(KDchar *buffer, KDsize buflen, KDint number);
      KDssize        kdUltostr(KDchar *buffer, KDsize buflen, KDuint number, KDint base);
      KDssize        kdFtostr(KDchar *buffer, KDsize buflen, KDfloat32 number);
      KDint          kdCryptoRandom(KDuint8 *buf, KDsize buflen);
      const KDchar*  kdGetLocale(void);
      void*          kdMalloc(KDsize size);
      void           kdFree(void *ptr);
      void*          kdRealloc(void *ptr, KDsize size);
      void*          kdGetTLS(void);
      void           kdSetTLS(void *ptr);

      KDfloat32      kdAcosf(KDfloat32 x);
      KDfloat32      kdAsinf(KDfloat32 x);
      KDfloat32      kdAtanf(KDfloat32 x);
      KDfloat32      kdAtan2f(KDfloat32 y, KDfloat32 x);
      KDfloat32      kdCosf(KDfloat32 x);
      KDfloat32      kdSinf(KDfloat32 x);
      KDfloat32      kdTanf(KDfloat32 x);
      KDfloat32      kdExpf(KDfloat32 x);
      KDfloat32      kdLogf(KDfloat32 x);
      KDfloat32      kdFabsf(KDfloat32 x);
      KDfloat32      kdPowf(KDfloat32 x, KDfloat32 y);
      KDfloat32      kdSqrtf(KDfloat32 x);
      KDfloat32      kdCeilf(KDfloat32 x);
      KDfloat32      kdFloorf(KDfloat32 x);
      KDfloat32      kdRoundf(KDfloat32 x);
      KDfloat32      kdInvsqrtf(KDfloat32 x);
      KDfloat32      kdFmodf(KDfloat32 x, KDfloat32 y);

      void*          kdMemchr(const void *src, KDint byte, KDsize len);
      KDint          kdMemcmp(const void *src1, const void *src2, KDsize len);
      void*          kdMemcpy(void *buf, const void *src, KDsize len);
      void*          kdMemmove(void *buf, const void *src, KDsize len);
      void*          kdMemset(void *buf, KDint byte, KDsize len);
      KDchar*        kdStrchr(const KDchar *str, KDint ch);
      KDint          kdStrcmp(const KDchar *str1, const KDchar *str2);
      KDsize         kdStrlen(const KDchar *str);
      KDsize         kdStrnlen(const KDchar *str, KDsize maxlen);
      KDint          kdStrncat_s(KDchar *buf, KDsize buflen, const KDchar *src, KDsize srcmaxlen);
      KDint          kdStrncmp(const KDchar *str1, const KDchar *str2, KDsize maxlen);
      KDint          kdStrcpy_s(KDchar *buf, KDsize buflen, const KDchar *src);
      KDint          kdStrncpy_s(KDchar *buf, KDsize buflen, const KDchar *src, KDsize srclen);
      KDust          kdGetTimeUST(void);
      KDtime         kdTime(KDtime *timep);

      KDTm*          kdGmtime_r(const KDtime *timep, KDTm *result);
      KDTm*          kdLocaltime_r(const KDtime *timep, KDTm *result);
      KDust          kdUSTAtEpoch(void);
      
      KDTimer*       kdSetTimer(KDint64 interval, KDint periodic, void *eventuserptr);
      KDint          kdCancelTimer(KDTimer *timer);

      KDFile*        kdFopen(const KDchar *pathname, const KDchar *mode);
      KDint          kdFclose(KDFile *file);
      KDint          kdFflush(KDFile *file);
      KDsize         kdFread(void *buffer, KDsize size, KDsize count, KDFile *file);
      KDsize         kdFwrite(const void *buffer, KDsize size, KDsize count, KDFile *file);
      KDint          kdGetc(KDFile *file);
      KDint          kdPutc(KDint c, KDFile *file);
      KDchar*        kdFgets(KDchar *buffer, KDsize buflen, KDFile *file);
      KDint          kdFEOF(KDFile *file);
      KDint          kdFerror(KDFile *file);
      void           kdClearerr(KDFile *file);
      KDint          kdFseek(KDFile *file, KDoff offset, KDfileSeekOrigin origin);
      KDoff          kdFtell(KDFile *file);
      KDint          kdMkdir(const KDchar *pathname);
      KDint          kdRmdir(const KDchar *pathname);
      KDint          kdRename(const KDchar *src, const KDchar *dest);
      KDint          kdRemove(const KDchar *pathname);
      KDint          kdTruncate(const KDchar *pathname, KDoff length);
      KDint          kdStat(const KDchar *pathname, struct KDStat *buf);
      KDint          kdFstat(KDFile *file, struct KDStat *buf);
      KDint          kdAccess(const KDchar *pathname, KDint amode);
      KDDir*         kdOpenDir(const KDchar *pathname);
      KDDirent*      kdReadDir(KDDir *dir);
      KDint          kdCloseDir(KDDir *dir);
      KDoff          kdGetFree(const KDchar *pathname);

      KDint          kdNameLookup(KDint af, const KDchar *hostname, void *eventuserptr);
      void           kdNameLookupCancel(void *eventuserptr);
      KDSocket*      kdSocketCreate(KDint type, void *eventuserptr);
      KDint          kdSocketClose(KDSocket *socket);
      KDint          kdSocketBind(KDSocket *socket, const struct KDSockaddr *addr, KDboolean reuse);
      KDint          kdSocketGetName(KDSocket *socket, struct KDSockaddr *addr);
      KDint          kdSocketConnect(KDSocket *socket, const KDSockaddr *addr);
      KDint          kdSocketListen(KDSocket *socket, KDint backlog);
      KDSocket*      kdSocketAccept(KDSocket *socket, KDSockaddr *addr, void *eventuserptr);
      KDint          kdSocketSend(KDSocket *socket, const void *buf, KDint len);
      KDint          kdSocketSendTo(KDSocket *socket, const void *buf, KDint len, const KDSockaddr *addr);
      KDint          kdSocketRecv(KDSocket *socket, void *buf, KDint len);
      KDint          kdSocketRecvFrom(KDSocket *socket, void *buf, KDint len, KDSockaddr *addr);
      KDuint32       kdHtonl(KDuint32 hostlong);
      KDuint16       kdHtons(KDuint16 hostshort);
      KDuint32       kdNtohl(KDuint32 netlong);
      KDuint16       kdNtohs(KDuint16 netshort);
      KDint          kdInetAton(const KDchar *cp, KDuint32 *inp);
      const KDchar*  kdInetNtop(KDuint af, const void *src, KDchar *dst, KDsize cnt);
      
      KDint          kdStateGeti(KDint startidx, KDuint numidxs, KDint32 *buffer);
      KDint          kdStateGetl(KDint startidx, KDuint numidxs, KDint64 *buffer);
      KDint          kdStateGetf(KDint startidx, KDuint numidxs, KDfloat32 *buffer);
      KDint          kdOutputSeti(KDint startidx, KDuint numidxs, const KDint32 *buffer);
      KDint          kdOutputSetf(KDint startidx, KDuint numidxs, const KDfloat32 *buffer);
      
      KDWindow*      kdCreateWindow(void* EGLDisplay, void* EGLConfig, void *eventuserptr);
      KDint          kdDestroyWindow(KDWindow *window);
      KDint          kdSetWindowPropertybv(KDWindow *window, KDint pname, const KDboolean *param);
      KDint          kdSetWindowPropertyiv(KDWindow *window, KDint pname, const KDint32 *param);
      KDint          kdSetWindowPropertycv(KDWindow *window, KDint pname, const KDchar *param);
      KDint          kdGetWindowPropertybv(KDWindow *window, KDint pname, KDboolean *param);
      KDint          kdGetWindowPropertyiv(KDWindow *window, KDint pname, KDint32 *param);
      KDint          kdGetWindowPropertycv(KDWindow *window, KDint pname, KDchar *param, KDsize *size);
      KDint          kdRealizeWindow(KDWindow *window, void* EGLNativeWindow );

      void           kdHandleAssertion(const KDchar *condition, const KDchar *filename, KDint linenumber);
      void           kdLogMessage(const KDchar *string);
      
]]

--[==[
#define KD_LTOSTR_MAXLEN ((sizeof(KDint)*8*3+6)/10+2)
#define KD_ULTOSTR_MAXLEN ((sizeof(KDint)*8+2)/3+1)
#define KD_E_F 2.71828175F
#define KD_PI_F 3.14159274F
#define KD_PI_2_F 1.57079637F
#define KD_2PI_F 6.28318548F
#define KD_LOG2E_F 1.44269502F
#define KD_LOG10E_F 0.434294492F
#define KD_LN2_F 0.693147182F
#define KD_LN10_F 2.30258512F
#define KD_PI_4_F 0.785398185F
#define KD_1_PI_F 0.318309873F
#define KD_2_PI_F 0.636619747F
#define KD_2_SQRTPI_F 1.12837923F
#define KD_SQRT2_F 1.41421354F
#define KD_SQRT1_2_F 0.707106769F
#define KD_FLT_EPSILON 1.19209290E-07F
#define KD_FLT_MAX 3.40282346638528860e+38F
#define KD_FLT_MIN 1.17549435e-38F
#define kdIsNan(x) (((x) != (x)) ? 1 : 0)
#define KD_HUGE_VALF KD_INFINITY
#define KD_DEG_TO_RAD_F 0.0174532924F
#define KD_RAD_TO_DEG_F 57.2957802F
--]==]

return kd