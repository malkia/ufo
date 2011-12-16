local ffi = require( "ffi" )
local pdl = ffi.load( "PDL" )

local libs = ffi_pdl_libs or {
   Windows = { x86 = "pdl.dll" },
   OSX     = { x86 = "/opt/PalmPDK/host/lib/libpdl.dylib" },
   Linux   = { x86 = "/opt/PalmPDK/host/lib/libpdl.so" }
}

local pdl = ffi.load( ffi_pdl_lib or libs[ os.arch ][ ffi.arch ] or "pdl" )

ffi.cdef[[
      enum {
	 PDL_HARDWARE_UNKNOWN     = -1,
	 PDL_HARDWARE_PRE         = 101,
	 PDL_HARDWARE_PRE_PLUS    = 102,
	 PDL_HARDWARE_PIXI        = 201,
	 PDL_HARDWARE_VEER        = 301,
	 PDL_HARDWARE_PRE_2       = 401,
	 PDL_HARDWARE_PRE_3       = 501,
	 PDL_HARDWARE_TOUCHPAD    = 601,
	 PDL_CALLBACK_PAYLOAD_MAX = 1024,
	 PDL_GPS_UPDATE           = 0xE100,
	 PDL_GPS_FAILURE          = 0xE101,
	 PDL_COMPASS              = 0xE110,
	 PDL_PENDING_JS           = 0xE120,
      };

      typedef enum PDL_Err {
	 PDL_NOERROR,
	 PDL_EMEMORY,
	 PDL_ECONNECTION,
	 PDL_INVALIDINPUT,
	 PDL_EOTHER,
	 PDL_UNINIT,
	 PDL_NOTALLOWED,
	 PDL_LICENSEFAILURE,
	 PDL_STRINGTOOSMALL,
	 PDL_SYSTEMERROR_FILE,
	 PDL_SYSTEMERROR_NET,
	 PDL_APPINFO,
	 PDL_ESTATE
      } PDL_Err;

      typedef enum PDL_Orientation {
	 PDL_ORIENTATION_0,
	 PDL_ORIENTATION_90,
	 PDL_ORIENTATION_180,
	 PDL_ORIENTATION_270
      } PDL_Orientation;

      enum {
	 PDLK_GESTURE_AREA             = 231,
	 PDLK_GESTURE_BACK             = 27,
	 PDLK_GESTURE_FORWARD          = 229,
	 PDLK_GESTURE_DISMISS_KEYBOARD = 24
      };

      typedef enum PDL_TouchAggression {
	 PDL_AGGRESSION_LESSTOUCHES,
	 PDL_AGGRESSION_MORETOUCHES
      } PDL_TouchAggression;

      typedef enum PDL_OGLVersion {
	 PDL_OGL_1_1,
	 PDL_OGL_2_0
      } PDL_OGLVersion;

      typedef struct PDL_NetInfo {
	 uint32_t ipaddress;
	 uint32_t netmask;
	 uint32_t broadcast;
      } PDL_NetInfo;

      typedef struct PDL_Location {
	 double latitude;
	 double longitude;
	 double altitude;
	 double horizontalAccuracy;
	 double verticalAccuracy;
	 double heading;
	 double velocity;
      } PDL_Location;

      typedef struct PDL_Compass {
	 int confidence;
	 double magneticBearing;
	 double trueBearing;
      } PDL_Compass;

      typedef struct PDL_ScreenMetrics {
	 int horizontalPixels;
	 int verticalPixels;
	 int horizontalDPI;
	 int verticalDPI;
	 double aspectRatio;
      } PDL_ScreenMetrics;

      typedef struct PDL_OSVersion {
	 int majorVersion;
	 int minorVersion;
	 int revision;
	 char versionStr[ 256 ];
      } PDL_OSVersion;

      typedef struct      PDL_ServiceParameters          PDL_ServiceParameters;
      typedef struct      PDL_JSParameters               PDL_JSParameters;
      typedef struct      PDL_ItemInfo                   PDL_ItemInfo;
      typedef struct      PDL_ItemReceipt                PDL_ItemReceipt;
      typedef struct      PDL_ItemCollection             PDL_ItemCollection;

      typedef PDL_bool (* PDL_ServiceCallbackFunc     )( PDL_ServiceParameters* params, void *user );
      typedef PDL_bool (* PDL_JSHandlerFunc           )( PDL_JSParameters*      params );

      PDL_Err             PDL_Init(                      unsigned int flags );
      PDL_Err             PDL_LaunchEmail(               const char* Subject, const char* Body );
      PDL_Err             PDL_LaunchEmailTo(             const char* Subject, const char* Body, int numRecipients, const char** recipients );
      PDL_Err             PDL_LaunchBrowser(             const char* Url );
      const char*         PDL_GetKeyName(                PDL_key Key );
      PDL_Err             PDL_GetLanguage(               char* buffer, int bufferLen );
      PDL_Err             PDL_GetRegionCountryName(      char* buffer, int bufferLen );
      PDL_Err             PDL_GetRegionCountryCode(      char* buffer, int bufferLen );
      PDL_Err             PDL_GetNetInfo(                const char *interfaceName, PDL_NetInfo* interfaceInfo);
      PDL_Err             PDL_SetOrientation(            PDL_Orientation orientation );
      PDL_Err             PDL_BannerMessagesEnable(      PDL_bool Enable );
      PDL_Err             PDL_GesturesEnable(            PDL_bool Enable );
      PDL_Err             PDL_CustomPauseUiEnable(       PDL_bool Enable );
      PDL_Err             PDL_NotifyMusicPlaying(        PDL_bool MusicPlaying );
      PDL_Err             PDL_SetAutomaticSoundPausing(  PDL_bool AutomaticallyPause );
      PDL_Err             PDL_SetFirewallPortStatus(     int port, PDL_bool Open );
      PDL_Err             PDL_GetUniqueID(               char* buffer, int bufferLen );
      PDL_Err             PDL_GetDeviceName(             char* buffer, int bufferLen );
      PDL_Err             PDL_GetDataFilePath(           const char* dataFileName, char* buffer, int bufferLen );
      PDL_Err             PDL_GetAppinfoValue(           const char* name,         char* buffer, int bufferLen );
      PDL_Err             PDL_EnableLocationTracking(    PDL_bool activate);
      PDL_Err             PDL_GetLocation(               PDL_Location* location);
      PDL_bool            PDL_IsPlugin(                  );
      int                 PDL_GetHardwareID(             );
      PDL_Err             PDL_GetScreenMetrics(          PDL_ScreenMetrics* outMetrics );
      const char*         PDL_GetError(                  );
      PDL_Err             PDL_GetOSVersion(              PDL_OSVersion* osVersion );
      int                 PDL_GetPDKVersion(             );
      PDL_Err             PDL_SetTouchAggression(        PDL_TouchAggression aggression );
      PDL_Err             PDL_Minimize(                  );
      PDL_Err             PDL_Vibrate(                   int periodMS, int durationMS);
      PDL_Err             PDL_EnableCompass(             PDL_bool activate );
      PDL_Err             PDL_GetCompass(                PDL_Compass* compass );
      PDL_Err             PDL_SetKeyboardState(          PDL_bool bVisible );
      PDL_Err             PDL_LoadOGL(                   PDL_OGLVersion version );
      void                PDL_Log(                       const char* format, ... );
      void                PDL_Quit(                      );
      PDL_Err             PDL_RegisterJSHandler(         const char *functionName, PDL_JSHandlerFunc func );
      PDL_Err             PDL_RegisterPollingJSHandler(  const char *functionName, PDL_JSHandlerFunc func );
      PDL_Err             PDL_JSRegistrationComplete(    );
      int                 PDL_HandleJSCalls(             );
      const char*         PDL_GetJSFunctionName(         PDL_JSParameters *parms );
      PDL_bool            PDL_IsPoller(                  PDL_JSParameters *parms );
      int                 PDL_GetNumJSParams(            PDL_JSParameters *parms );
      const char*         PDL_GetJSParamString(          PDL_JSParameters *parms, int paramNum );
      int                 PDL_GetJSParamInt(             PDL_JSParameters *parms, int paramNum );
      double              PDL_GetJSParamDouble(          PDL_JSParameters *parms, int paramNum );
      PDL_Err             PDL_JSReply(                   PDL_JSParameters *parms, const char *reply );
      PDL_Err             PDL_JSException(               PDL_JSParameters *parms, const char *reply );
      PDL_Err             PDL_CallJS(                    const char* functionName, const char **params, int numParams );
      SDL_Surface*        PDL_SetFullscreen(             int width, int height, int bpp, Uint32 flags );
      PDL_Err             PDL_DismissFullscreen(         );
      PDL_bool            PDL_IsFullscreenPlugin(        );
      PDL_Err             PDL_ServiceCall(               const char* uri, const char* payload );
      PDL_Err             PDL_ServiceCallWithCallback(   const char *uri, const char *payload, PDL_ServiceCallbackFunc callback, void *user, PDL_bool removeAfterResponse );
      PDL_Err             PDL_UnregisterServiceCallback( PDL_ServiceCallbackFunc callback )
      PDL_bool            PDL_ParamExists(               PDL_ServiceParameters *parms, const char *name );
      void 	          PDL_GetParamString(            PDL_ServiceParameters *parms, const char *name, char *buffer, int bufferLen );
      int                 PDL_GetParamInt(               PDL_ServiceParameters *parms, const char *name );
      double              PDL_GetParamDouble(            PDL_ServiceParameters *parms, const char *name );
      PDL_bool            PDL_GetParamBool(              PDL_ServiceParameters *parms, const char *name );
      const char*         PDL_GetParamJson(              PDL_ServiceParameters *parms );
      PDL_ItemCollection* PDL_GetAvailableItems(         );
      PDL_ItemReceipt*    PDL_PurchaseItem(              const char* itemID, int qty, const char* usr );
      PDL_ItemInfo*       PDL_GetItemInfo(               const char* itemID );
      PDL_ItemReceipt*    PDL_GetPendingPurchaseInfo(    const char* orderNo );
      const char*         PDL_GetItemJSON(               PDL_ItemInfo *itemInfo );
      const char*         PDL_GetItemReceiptJSON(        PDL_ItemReceipt *receipt );
      const char*         PDL_GetItemCollectionJSON(     PDL_ItemCollection *itemCollectionInfo );
      void                PDL_FreeItemInfo(              PDL_ItemInfo *itemInfo );
      void                PDL_FreeItemReceipt(           PDL_ItemReceipt *itemInfo );
      void                PDL_FreeItemCollection(        PDL_ItemCollection *itemCollectionInfo );
]]

return pdl
