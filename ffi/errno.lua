local ffi = require( "ffi" )


ffi.cdef[[
      enum {
         EPERM           = 1,
         ENOENT          = 2,
         ESRCH           = 3,
         EINTR           = 4,
         EIO             = 5,
         ENXIO           = 6,
         E2BIG           = 7,
         ENOEXEC         = 8,
         EBADF           = 9,
         ECHILD          = 10,
         //EGAIN=11 (Windows?)
         ENOMEM          = 12,
         EACCES          = 13,
         EFAULT          = 14,
         ENOTBLK         = 15,
         EBUSY           = 16,
         EEXIST          = 17,
         EXDEV           = 18,
         ENODEV          = 19,
         ENOTDIR         = 20,
         EISDIR          = 21,
         EINVAL          = 22,
         ENFILE          = 23,
         EMFILE          = 24,
         ENOTTY          = 25,
         EFBIG           = 27,
         ENOSPC          = 28,
         ESPIPE          = 29,
         EROFS           = 30,
         EMLINK          = 31,
         EPIPE           = 32,
         EDOM            = 33,
         ERANGE          = 34,
         //EAGAIN=35 (OSX)
         //EINPROGRESS=36 (OSX),
         EALREADY        = 37,
         //38
         EPROTONOSUPPORT = 43,
         ESOCKTNOSUPPORT = 44,
         EPFNOSUPPORT    = 46,
         EAFNOSUPPORT    = 47,
         EADDRINUSE      = 48,
         EADDRNOTAVAIL   = 49,
         ENETDOWN        = 50,
         ENETUNREACH     = 51,
         ENETRESET       = 52,
         ECONNABORTED    = 53,
         ECONNRESET      = 54,
         ENOBUFS         = 55,
         EISCONN         = 56,
         ENOTCONN        = 57,
         ESHUTDOWN       = 58,
         ETOOMANYREFS    = 59,   
         ETIMEDOUT       = 60,   
         ECONNREFUSED    = 61,   
         ELOOP           = 62,   
         ENAMETOOLONG    = 63,   
         EHOSTDOWN       = 64,   
         EHOSTUNREACH    = 65,   
         EPROCLIM        = 67,   
         EUSERS          = 68,   
         EDQUOT          = 69,   
         ESTALE          = 70,   
         EREMOTE         = 71,   
         EBADRPC         = 72,   
         ERPCMISMATCH    = 73,   
         EPROGUNAVAIL    = 74,   
         EPROGMISMATCH   = 75,   
         EPROCUNAVAIL    = 76,   
         EFTYPE          = 79,   
         EAUTH           = 80,   
         ENEEDAUTH       = 81,   
         EPWROFF         = 82,   
         EDEVERR         = 83,   
         EOVERFLOW       = 84,   
         EBADEXEC        = 85,   
         EBADARCH        = 86,   
         ESHLIBVERS      = 87,   
         EBADMACHO       = 88,   
         ECANCELED       = 89,   
         EIDRM           = 90,   
         ENOMSG          = 91,   
         ENOATTR         = 93,   
         EBADMSG         = 94,   
         EMULTIHOP       = 95,   
         ENODATA         = 96,   
         ENOLINK         = 97,   
         ENOSR           = 98,   
         ENOSTR          = 99,   
         EPROTO          = 100,  
         ETIME           = 101,
         ENOPOLICY       = 103,
         ENOTRECOVERABLE = 104,
         EOWNERDEAD      = 105,
         ELAST           = 105,
      };
]]

if ffi.os ~= "Windows" then 
   ffi.cdef[[
       enum {
         EDEADLK =  11,
         EAGAIN  =  35,
         ENOTSOCK = 38,
         EINPROGRESS = 36,
         ENOLCK          = 77,   
         ENOSYS          = 78,   
         ENOTEMPTY       = 66,   
         EILSEQ          = 92,   
         EOPNOTSUPP      = 102, 
      };
   ]]
else
   ffi.cdef[[
       enum {
         EAGAIN  = 11,
         EDEADLK = 36,
         ENAMETOOLONG    = 38,
         ENOLCK          = 39,
         ENOTEMPTY       = 41,
         EILSEQ          = 42,
         ENOTSUP         = 45,
         EOPNOTSUPP      = ENOTSUP,
         STRUNCACE = 80, // Windows
         ENOSYS          = 40,
       };
   ]]
end

ffi.cdef[[
      enum {
        EDEADLOCK       = EDEADLK,
         EWOULDBLOCK     = EAGAIN,
      };
]]

return ffi.C
