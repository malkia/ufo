local ffi  = require( "ffi" )
local libs = ffi_egl_libs or {
   OSX     = { x86 = "bin/OSX/egl.dylib", x64 = "bin/OSX/egl.dylib" },
   Windows = { x86 = "bin/Windows/x86/libEGL.dll", x64 = "bin/Windows/x64/libEGL.dll" },
   Linux   = { x86 = "bin/Linux/x86/libEGL.so.1", x64 = "bin/Linux/x64//libEGL.so.1", arm = "EGL" }
}
local lib = ffi_EGL_lib or libs[ ffi.os ][ ffi.arch ]

local egl  = ffi.load( lib )

ffi.cdef[[
      enum {
	 EGL_FALSE                       = 0,
	 EGL_TRUE                        = 1,
	 EGL_VERSION_1_0                 = 1,
	 EGL_VERSION_1_1                 = 1,
	 EGL_VERSION_1_2                 = 1,
	 EGL_VERSION_1_3                 = 1,
	 EGL_VERSION_1_4                 = 1,
	 EGL_DEFAULT_DISPLAY		 = 0,
	 EGL_NO_CONTEXT			 = 0,
	 EGL_NO_DISPLAY			 = 0,
	 EGL_NO_SURFACE	 		 = 0,
	 EGL_DONT_CARE		 	 = -1,
	 EGL_SUCCESS			 = 0x3000,
	 EGL_NOT_INITIALIZED		 = 0x3001,
	 EGL_BAD_ACCESS			 = 0x3002,
	 EGL_BAD_ALLOC			 = 0x3003,
	 EGL_BAD_ATTRIBUTE		 = 0x3004,
	 EGL_BAD_CONFIG			 = 0x3005,
	 EGL_BAD_CONTEXT		 = 0x3006,
	 EGL_BAD_CURRENT_SURFACE	 = 0x3007,
	 EGL_BAD_DISPLAY		 = 0x3008,
	 EGL_BAD_MATCH			 = 0x3009,
	 EGL_BAD_NATIVE_PIXMAP		 = 0x300A,
	 EGL_BAD_NATIVE_WINDOW		 = 0x300B,
	 EGL_BAD_PARAMETER		 = 0x300C,
	 EGL_BAD_SURFACE		 = 0x300D,
	 EGL_CONTEXT_LOST		 = 0x300E,
	 EGL_BUFFER_SIZE		 = 0x3020,
	 EGL_ALPHA_SIZE			 = 0x3021,
	 EGL_BLUE_SIZE			 = 0x3022,
	 EGL_GREEN_SIZE			 = 0x3023,
	 EGL_RED_SIZE			 = 0x3024,
	 EGL_DEPTH_SIZE			 = 0x3025,
	 EGL_STENCIL_SIZE		 = 0x3026,
	 EGL_CONFIG_CAVEAT		 = 0x3027,
	 EGL_CONFIG_ID			 = 0x3028,
	 EGL_LEVEL			 = 0x3029,
	 EGL_MAX_PBUFFER_HEIGHT		 = 0x302A,
	 EGL_MAX_PBUFFER_PIXELS		 = 0x302B,
	 EGL_MAX_PBUFFER_WIDTH		 = 0x302C,
	 EGL_NATIVE_RENDERABLE		 = 0x302D,
	 EGL_NATIVE_VISUAL_ID		 = 0x302E,
	 EGL_NATIVE_VISUAL_TYPE		 = 0x302F,
	 EGL_SAMPLES			 = 0x3031,
	 EGL_SAMPLE_BUFFERS		 = 0x3032,
	 EGL_SURFACE_TYPE		 = 0x3033,
	 EGL_TRANSPARENT_TYPE		 = 0x3034,
	 EGL_TRANSPARENT_BLUE_VALUE	 = 0x3035,
	 EGL_TRANSPARENT_GREEN_VALUE	 = 0x3036,
	 EGL_TRANSPARENT_RED_VALUE	 = 0x3037,
	 EGL_NONE			 = 0x3038,
	 EGL_BIND_TO_TEXTURE_RGB	 = 0x3039,
	 EGL_BIND_TO_TEXTURE_RGBA	 = 0x303A,
	 EGL_MIN_SWAP_INTERVAL		 = 0x303B,
	 EGL_MAX_SWAP_INTERVAL		 = 0x303C,
	 EGL_LUMINANCE_SIZE		 = 0x303D,
	 EGL_ALPHA_MASK_SIZE		 = 0x303E,
	 EGL_COLOR_BUFFER_TYPE		 = 0x303F,
	 EGL_RENDERABLE_TYPE		 = 0x3040,
	 EGL_MATCH_NATIVE_PIXMAP	 = 0x3041,
	 EGL_CONFORMANT			 = 0x3042,
	 EGL_SLOW_CONFIG		 = 0x3050,
	 EGL_NON_CONFORMANT_CONFIG	 = 0x3051,
	 EGL_TRANSPARENT_RGB		 = 0x3052,
	 EGL_RGB_BUFFER			 = 0x308E,
	 EGL_LUMINANCE_BUFFER		 = 0x308F,
	 EGL_NO_TEXTURE			 = 0x305C,
	 EGL_TEXTURE_RGB		 = 0x305D,
	 EGL_TEXTURE_RGBA		 = 0x305E,
	 EGL_TEXTURE_2D			 = 0x305F,
	 EGL_PBUFFER_BIT		 = 0x0001,
	 EGL_PIXMAP_BIT			 = 0x0002,
	 EGL_WINDOW_BIT			 = 0x0004,
	 EGL_VG_COLORSPACE_LINEAR_BIT	 = 0x0020,
	 EGL_VG_ALPHA_FORMAT_PRE_BIT	 = 0x0040,
	 EGL_MULTISAMPLE_RESOLVE_BOX_BIT = 0x0200,
	 EGL_SWAP_BEHAVIOR_PRESERVED_BIT = 0x0400,
	 EGL_OPENGL_ES_BIT		 = 0x0001,
	 EGL_OPENVG_BIT			 = 0x0002,
	 EGL_OPENGL_ES2_BIT		 = 0x0004,
	 EGL_OPENGL_BIT			 = 0x0008,
	 EGL_VENDOR			 = 0x3053,
	 EGL_VERSION			 = 0x3054,
	 EGL_EXTENSIONS			 = 0x3055,
	 EGL_CLIENT_APIS		 = 0x308D,
	 EGL_HEIGHT			 = 0x3056,
	 EGL_WIDTH			 = 0x3057,
	 EGL_LARGEST_PBUFFER		 = 0x3058,
	 EGL_TEXTURE_FORMAT		 = 0x3080,
	 EGL_TEXTURE_TARGET		 = 0x3081,
	 EGL_MIPMAP_TEXTURE		 = 0x3082,
	 EGL_MIPMAP_LEVEL		 = 0x3083,
	 EGL_RENDER_BUFFER		 = 0x3086,
	 EGL_VG_COLORSPACE		 = 0x3087,
	 EGL_VG_ALPHA_FORMAT		 = 0x3088,
	 EGL_HORIZONTAL_RESOLUTION	 = 0x3090,
	 EGL_VERTICAL_RESOLUTION	 = 0x3091,
	 EGL_PIXEL_ASPECT_RATIO		 = 0x3092,
	 EGL_SWAP_BEHAVIOR		 = 0x3093,
	 EGL_MULTISAMPLE_RESOLVE	 = 0x3099,
	 EGL_BACK_BUFFER		 = 0x3084,
	 EGL_SINGLE_BUFFER		 = 0x3085,
	 EGL_VG_COLORSPACE_sRGB		 = 0x3089,
	 EGL_VG_COLORSPACE_LINEAR	 = 0x308A,
	 EGL_VG_ALPHA_FORMAT_NONPRE	 = 0x308B,
	 EGL_VG_ALPHA_FORMAT_PRE	 = 0x308C,
	 EGL_DISPLAY_SCALING		 = 10000,
	 EGL_UNKNOWN			 = -1,
	 EGL_BUFFER_PRESERVED		 = 0x3094,
	 EGL_BUFFER_DESTROYED		 = 0x3095,
	 EGL_OPENVG_IMAGE		 = 0x3096,
	 EGL_CONTEXT_CLIENT_TYPE	 = 0x3097,
	 EGL_CONTEXT_CLIENT_VERSION	 = 0x3098,
	 EGL_MULTISAMPLE_RESOLVE_DEFAULT = 0x309A,
	 EGL_MULTISAMPLE_RESOLVE_BOX	 = 0x309B,
	 EGL_OPENGL_ES_API		 = 0x30A0,
	 EGL_OPENVG_API			 = 0x30A1,
	 EGL_OPENGL_API			 = 0x30A2,
	 EGL_DRAW			 = 0x3059,
	 EGL_READ			 = 0x305A,
	 EGL_CORE_NATIVE_ENGINE		 = 0x305B,
      };

      typedef int   EGLNativeDisplayType;
      typedef void *EGLNativeWindowType;
      typedef void *EGLNativePixmapType;

      typedef int32_t  EGLint;
      typedef unsigned EGLBoolean;
      typedef unsigned EGLenum;
      typedef void*    EGLConfig;
      typedef void*    EGLContext;
      typedef void*    EGLDisplay;
      typedef void*    EGLSurface;
      typedef void*    EGLClientBuffer;

      EGLint      eglGetError(             );
      EGLDisplay  eglGetDisplay(           EGLNativeDisplayType display_id );
      EGLBoolean  eglInitialize(           EGLDisplay, EGLint *major, EGLint *minor );
      EGLBoolean  eglTerminate(            EGLDisplay  );
      const char* eglQueryString(          EGLDisplay, EGLint name );
      EGLBoolean  eglGetConfigs(           EGLDisplay, EGLConfig*, EGLint size, EGLint* n );
      EGLBoolean  eglChooseConfig(         EGLDisplay, const EGLint* alist, EGLConfig*, EGLint n, EGLint *r );
      EGLBoolean  eglGetConfigAttrib(      EGLDisplay, EGLConfig, EGLint attribute, EGLint *value);
      EGLSurface  eglCreateWindowSurface(  EGLDisplay, EGLConfig, EGLNativeWindowType, const EGLint *atrlst );
      EGLSurface  eglCreatePbufferSurface( EGLDisplay, EGLConfig, const EGLint *attrib_list );
      EGLSurface  eglCreatePixmapSurface(  EGLDisplay, EGLConfig, EGLNativePixmapType, const EGLint *attrlst );
      EGLBoolean  eglDestroySurface(       EGLDisplay, EGLSurface );
      EGLBoolean  eglQuerySurface(         EGLDisplay, EGLSurface, EGLint attr, EGLint *value );
      EGLBoolean  eglBindAPI(              EGLenum api );
      EGLenum     eglQueryAPI(             );
      EGLBoolean  eglWaitClient(           );
      EGLBoolean  eglReleaseThread(        );
      EGLBoolean  eglSurfaceAttrib(        EGLDisplay, EGLSurface, EGLint attribute, EGLint value );
      EGLBoolean  eglBindTexImage(         EGLDisplay, EGLSurface, EGLint buffer );
      EGLBoolean  eglReleaseTexImage(      EGLDisplay, EGLSurface, EGLint buffer );
      EGLBoolean  eglSwapInterval(         EGLDisplay, EGLint interval );
      EGLContext  eglCreateContext(        EGLDisplay, EGLConfig, EGLContext, const EGLint* atrlst );
      EGLBoolean  eglDestroyContext(       EGLDisplay, EGLContext );
      EGLBoolean  eglMakeCurrent(          EGLDisplay, EGLSurface draw, EGLSurface read, EGLContext );
      EGLContext  eglGetCurrentContext(    );
      EGLSurface  eglGetCurrentSurface(    EGLint readdraw );
      EGLDisplay  eglGetCurrentDisplay(    );
      EGLBoolean  eglQueryContext(         EGLDisplay dpy, EGLContext, EGLint attr, EGLint *value );
      EGLBoolean  eglWaitGL(               );
      EGLBoolean  eglWaitNative(           EGLint engine );
      EGLBoolean  eglSwapBuffers(          EGLDisplay, EGLSurface );
      EGLBoolean  eglCopyBuffers(          EGLDisplay, EGLSurface, EGLNativePixmapType target );
      EGLSurface  eglCreatePbufferFromClientBuffer(
	                                   EGLDisplay, EGLenum buftype, EGLClientBuffer, EGLConfig,
	                                   const EGLint *attrib_list );

      typedef void (* __eglMustCastToProperFunctionPointerType )( void );
      __eglMustCastToProperFunctionPointerType eglGetProcAddress( const char *procname );
]]

local duh = [[
//	 EGL_COLORSPACE			 = EGL_VG_COLORSPACE,
//	 EGL_ALPHA_FORMAT		 = EGL_VG_ALPHA_FORMAT,
//	 EGL_COLORSPACE_sRGB		 = EGL_VG_COLORSPACE_sRGB,
//	 EGL_COLORSPACE_LINEAR		 = EGL_VG_COLORSPACE_LINEAR,
//	 EGL_ALPHA_FORMAT_NONPRE	 = EGL_VG_ALPHA_FORMAT_NONPRE,
//	 EGL_ALPHA_FORMAT_PRE		 = EGL_VG_ALPHA_FORMAT_PRE,
]]

return egl
