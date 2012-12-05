local ffi = require( "ffi" )

ffi.cdef [[

typedef uint32_t WFCDevice;
typedef uint32_t WFCContext;
typedef uint32_t WFCSource;
typedef uint32_t WFCMask;
typedef uint32_t WFCElement;
typedef uint32_t WFCNativeStreamType;

typedef enum WFCErrorCode {
  WFC_ERROR_NONE                          = 0,
  WFC_ERROR_OUT_OF_MEMORY                 = 0x7001,
  WFC_ERROR_ILLEGAL_ARGUMENT              = 0x7002,
  WFC_ERROR_UNSUPPORTED                   = 0x7003,
  WFC_ERROR_BAD_ATTRIBUTE                 = 0x7004,
  WFC_ERROR_IN_USE                        = 0x7005,
  WFC_ERROR_BUSY                          = 0x7006,
  WFC_ERROR_BAD_DEVICE                    = 0x7007,
  WFC_ERROR_BAD_HANDLE                    = 0x7008,
  WFC_ERROR_INCONSISTENCY                 = 0x7009,
} WFCErrorCode;

typedef enum WFCDeviceFilter {
  WFC_DEVICE_FILTER_SCREEN_NUMBER         = 0x7020,
} WFCDeviceFilter;

typedef enum WFCDeviceAttrib {
  WFC_DEVICE_CLASS                        = 0x7030,
  WFC_DEVICE_ID                           = 0x7031,
} WFCDeviceAttrib;

typedef enum WFCDeviceClass {
  WFC_DEVICE_CLASS_FULLY_CAPABLE          = 0x7040,
  WFC_DEVICE_CLASS_OFF_SCREEN_ONLY        = 0x7041,
} WFCDeviceClass;

typedef enum WFCContextAttrib {
  WFC_CONTEXT_TYPE                        = 0x7051,
  WFC_CONTEXT_TARGET_HEIGHT               = 0x7052,
  WFC_CONTEXT_TARGET_WIDTH                = 0x7053,
  WFC_CONTEXT_LOWEST_ELEMENT              = 0x7054,
  WFC_CONTEXT_ROTATION                    = 0x7061,
  WFC_CONTEXT_BG_COLOR                    = 0x7062,
} WFCContextAttrib;

typedef enum WFCContextType {
  WFC_CONTEXT_TYPE_ON_SCREEN              = 0x7071,
  WFC_CONTEXT_TYPE_OFF_SCREEN             = 0x7072,
  WFC_CONTEXT_TYPE_FORCE_32BIT            = 0x7FFFFFFF
} WFCContextType;

typedef enum WFCRotation {
  WFC_ROTATION_0                          = 0x7081,
  WFC_ROTATION_90                         = 0x7082,
  WFC_ROTATION_180                        = 0x7083,
  WFC_ROTATION_270                        = 0x7084,
  WFC_ROTATION_FORCE_32BIT                = 0x7FFFFFFF
} WFCRotation;

typedef enum WFCElementAttrib {
  WFC_ELEMENT_DESTINATION_RECTANGLE       = 0x7101,
  WFC_ELEMENT_SOURCE                      = 0x7102,
  WFC_ELEMENT_SOURCE_RECTANGLE            = 0x7103,
  WFC_ELEMENT_SOURCE_FLIP                 = 0x7104,
  WFC_ELEMENT_SOURCE_ROTATION             = 0x7105,
  WFC_ELEMENT_SOURCE_SCALE_FILTER         = 0x7106,
  WFC_ELEMENT_TRANSPARENCY_TYPES          = 0x7107,
  WFC_ELEMENT_GLOBAL_ALPHA                = 0x7108,
  WFC_ELEMENT_MASK                        = 0x7109,
  WFC_ELEMENT_FORCE_32BIT                 = 0x7FFFFFFF
} WFCElementAttrib;

typedef enum WFCScaleFilter {
  WFC_SCALE_FILTER_NONE                   = 0x7151,
  WFC_SCALE_FILTER_FASTER                 = 0x7152,
  WFC_SCALE_FILTER_BETTER                 = 0x7153,
  WFC_SCALE_FILTER_FORCE_32BIT            = 0x7FFFFFFF
} WFCScaleFilter;

typedef enum WFCTransparencyType {
  WFC_TRANSPARENCY_NONE                   = 0,
  WFC_TRANSPARENCY_ELEMENT_GLOBAL_ALPHA   = (1 << 0),
  WFC_TRANSPARENCY_SOURCE                 = (1 << 1),
  WFC_TRANSPARENCY_MASK                   = (1 << 2),
  WFC_TRANSPARENCY_FORCE_32BIT            = 0x7FFFFFFF
} WFCTransparencyType;

typedef enum WFCStringID {
  WFC_VENDOR                              = 0x7200,
  WFC_RENDERER                            = 0x7201,
  WFC_VERSION                             = 0x7202,
  WFC_EXTENSIONS                          = 0x7203,
  WFC_STRINGID_FORCE_32BIT                = 0x7FFFFFFF
} WFCStringID;

int          wfcEnumerateDevices(       int* deviceIds, int deviceIdsCount, const int* filterList );
WFCDevice    wfcCreateDevice(           int  deviceId,                      const int* attribList );
WFCErrorCode wfcGetError(               WFCDevice  );
int          wfcGetDeviceAttribi(       WFCDevice, WFCDeviceAttrib attrib );
WFCErrorCode wfcDestroyDevice(          WFCDevice  );
WFCContext   wfcCreateOnScreenContext(  WFCDevice, int screenNumber,    const int* attribList );
WFCContext   wfcCreateOffScreenContext( WFCDevice, WFCNativeStreamType, const int* attribList );
void         wfcCommit(                 WFCDevice, WFCContext, int wait );
int          wfcGetContextAttribi(      WFCDevice, WFCContext, WFCContextAttrib );
void         wfcGetContextAttribfv(     WFCDevice, WFCContext, WFCContextAttrib, int count,       float* values );
void         wfcSetContextAttribi(      WFCDevice, WFCContext, WFCContextAttrib, int value );
void         wfcSetContextAttribfv(     WFCDevice, WFCContext, WFCContextAttrib, int count, const float* values );
void         wfcDestroyContext(         WFCDevice, WFCContext  );
WFCSource    wfcCreateSourceFromStream( WFCDevice, WFCContext, WFCNativeStreamType, const int *attribList );
void         wfcDestroySource(          WFCDevice, WFCSource   );
WFCMask      wfcCreateMaskFromStream(   WFCDevice, WFCContext, WFCNativeStreamType, const int *attribList );
void         wfcDestroyMask(            WFCDevice, WFCMask     );
WFCElement   wfcCreateElement(          WFCDevice, WFCContext, const int *attribList );
int          wfcGetElementAttribi(      WFCDevice, WFCElement, WFCElementAttrib  );
float        wfcGetElementAttribf(      WFCDevice, WFCElement, WFCElementAttrib  );
void         wfcGetElementAttribiv(     WFCDevice, WFCElement, WFCElementAttrib, int   count, int*   values );
void         wfcGetElementAttribfv(     WFCDevice, WFCElement, WFCElementAttrib, int   count, float* values );
void         wfcSetElementAttribi(      WFCDevice, WFCElement, WFCElementAttrib, int   value  );
void         wfcSetElementAttribf(      WFCDevice, WFCElement, WFCElementAttrib, float value  );
void         wfcSetElementAttribiv(     WFCDevice, WFCElement, WFCElementAttrib, int   count, const int*   values );
void         wfcSetElementAttribfv(     WFCDevice, WFCElement, WFCElementAttrib, int   count, const float* values );
void         wfcInsertElement(          WFCDevice, WFCElement, WFCElement sub );
void         wfcRemoveElement(          WFCDevice, WFCElement  );
WFCElement   wfcGetElementAbove(        WFCDevice, WFCElement  );
WFCElement   wfcGetElementBelow(        WFCDevice, WFCElement  );
void         wfcDestroyElement(         WFCDevice, WFCElement  );
void         wfcActivate(               WFCDevice, WFCContext  );
void         wfcDeactivate(             WFCDevice, WFCContext  );
void         wfcCompose(                WFCDevice, WFCContext, int wait );
void         wfcFence(                  WFCDevice, WFCContext, void* egl_display, void* egl_sync );
int          wfcGetStrings(             WFCDevice, WFCStringID, const char **strings, int stringsCount );
int          wfcIsExtensionSupported(   WFCDevice, const char*  str );

]]
