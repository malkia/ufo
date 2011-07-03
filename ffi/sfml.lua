ffi.cdef[[
	typedef int                          sfBool;
	typedef int8_t                       sfInt8;
	typedef uint8_t                      sfUint8;
	typedef int16_t                      sfInt16;
	typedef uint16_t                     sfUint16;
	typedef int32_t                      sfInt32;
	typedef uint32_t                     sfUint32;
	typedef void*                        sfWindowHandle;
	typedef struct sfClock               sfClock;
	typedef struct sfMutex               sfMutex;
	typedef struct sfThread              sfThread;
	typedef struct sfContext             sfContext;
	typedef struct sfInput               sfInput;
	typedef struct sfWindow              sfWindow;
	typedef struct sfFont                sfFont;
	typedef struct sfImage               sfImage;
	typedef struct sfShader              sfShader;
	typedef struct sfRenderImage         sfRenderImage;
	typedef struct sfRenderWindow        sfRenderWindow;
	typedef struct sfShape               sfShape;
	typedef struct sfSprite              sfSprite;
	typedef struct sfText                sfText;
	typedef struct sfView                sfView;
	typedef struct sfMusic               sfMusic;
	typedef struct sfSound               sfSound;
	typedef struct sfSoundBuffer         sfSoundBuffer;
	typedef struct sfSoundBufferRecorder sfSoundBufferRecorder;
	typedef struct sfSoundRecorder       sfSoundRecorder;
	typedef struct sfSoundStream         sfSoundStream;

	typedef enum {
		CSFML_VERSION_MAJOR = 2,
		CSFML_VERSION_MINOR = 0,
	};
	
	enum {
	   sfFalse = 0,
	   sfTrue = 1,
	};
	
	typedef enum {
	    sfKeyA = 'a',
	    sfKeyB = 'b',
	    sfKeyC = 'c',
	    sfKeyD = 'd',
	    sfKeyE = 'e',
	    sfKeyF = 'f',
	    sfKeyG = 'g',
	    sfKeyH = 'h',
	    sfKeyI = 'i',
	    sfKeyJ = 'j',
	    sfKeyK = 'k',
	    sfKeyL = 'l',
	    sfKeyM = 'm',
	    sfKeyN = 'n',
	    sfKeyO = 'o',
	    sfKeyP = 'p',
	    sfKeyQ = 'q',
	    sfKeyR = 'r',
	    sfKeyS = 's',
	    sfKeyT = 't',
	    sfKeyU = 'u',
	    sfKeyV = 'v',
	    sfKeyW = 'w',
	    sfKeyX = 'x',
	    sfKeyY = 'y',
	    sfKeyZ = 'z',
	    sfKeyNum0 = '0',
	    sfKeyNum1 = '1',
	    sfKeyNum2 = '2',
	    sfKeyNum3 = '3',
	    sfKeyNum4 = '4',
	    sfKeyNum5 = '5',
	    sfKeyNum6 = '6',
	    sfKeyNum7 = '7',
	    sfKeyNum8 = '8',
	    sfKeyNum9 = '9', 
	    sfKeyEscape = 256,
	    sfKeyLControl,
	    sfKeyLShift,
	    sfKeyLAlt,
	    sfKeyLSystem,      ///< OS specific key (left side) : windows (Win and Linux), apple (MacOS), ...
	    sfKeyRControl,
	    sfKeyRShift,
	    sfKeyRAlt,
	    sfKeyRSystem,      ///< OS specific key (right side) : windows (Win and Linux), apple (MacOS), ...
	    sfKeyMenu,
	    sfKeyLBracket,     ///< [
	    sfKeyRBracket,     ///< ]
	    sfKeySemiColon,    ///< ;
	    sfKeyComma,        ///< ,
	    sfKeyPeriod,       ///< .
	    sfKeyQuote,        ///< '
	    sfKeySlash,        ///< /
	    sfKeyBackSlash,
	    sfKeyTilde,        ///< ~
	    sfKeyEqual,        ///< =
	    sfKeyDash,         ///< -
	    sfKeySpace,
	    sfKeyReturn,
	    sfKeyBack,
	    sfKeyTab,
	    sfKeyPageUp,
	    sfKeyPageDown,
	    sfKeyEnd,
	    sfKeyHome,
	    sfKeyInsert,
	    sfKeyDelete,
	    sfKeyAdd,          ///< +
	    sfKeySubtract,     ///< -
	    sfKeyMultiply,     ///< *
	    sfKeyDivide,       ///< /
	    sfKeyLeft,         ///< Left arrow
	    sfKeyRight,        ///< Right arrow
	    sfKeyUp,           ///< Up arrow
	    sfKeyDown,         ///< Down arrow
	    sfKeyNumpad0,
	    sfKeyNumpad1,
	    sfKeyNumpad2,
	    sfKeyNumpad3,
	    sfKeyNumpad4,
	    sfKeyNumpad5,
	    sfKeyNumpad6,
	    sfKeyNumpad7,
	    sfKeyNumpad8,
	    sfKeyNumpad9,
	    sfKeyF1,
	    sfKeyF2,
	    sfKeyF3,
	    sfKeyF4,
	    sfKeyF5,
	    sfKeyF6,
	    sfKeyF7,
	    sfKeyF8,
	    sfKeyF9,
	    sfKeyF10,
	    sfKeyF11,
	    sfKeyF12,
	    sfKeyF13,
	    sfKeyF14,
	    sfKeyF15,
	    sfKeyPause,
	    sfKeyCount // For internal use
	} sfKeyCode;

	typedef enum {
	    sfButtonLeft,
	    sfButtonRight,
	    sfButtonMiddle,
	    sfButtonX1,
	    sfButtonX2
	} sfMouseButton;

	typedef enum {
	    sfJoyAxisX,
	    sfJoyAxisY,
	    sfJoyAxisZ,
	    sfJoyAxisR,
	    sfJoyAxisU,
	    sfJoyAxisV,
	    sfJoyAxisPOV
	} sfJoyAxis;

	typedef enum {
	    sfEvtClosed,
	    sfEvtResized,
	    sfEvtLostFocus,
	    sfEvtGainedFocus,
	    sfEvtTextEntered,
	    sfEvtKeyPressed,
	    sfEvtKeyReleased,
	    sfEvtMouseWheelMoved,
	    sfEvtMouseButtonPressed,
	    sfEvtMouseButtonReleased,
	    sfEvtMouseMoved,
	    sfEvtMouseEntered,
	    sfEvtMouseLeft,
	    sfEvtJoyButtonPressed,
	    sfEvtJoyButtonReleased,
	    sfEvtJoyMoved
	} sfEventType;

	typedef struct sfKeyEvent {
	    sfEventType Type;
	    sfKeyCode   Code;
	    sfBool      Alt;
	    sfBool      Control;
	    sfBool      Shift;
	    sfBool      System;
	} sfKeyEvent;

	typedef struct sfTextEvent {
	    sfEventType Type;
	    sfUint32    Unicode;
	} sfTextEvent;

	typedef struct sfMouseMoveEvent	{
	    sfEventType Type;
	    int         X;
	    int         Y;
	} sfMouseMoveEvent;

	typedef struct sfMouseButtonEvent {
	    sfEventType   Type;
	    sfMouseButton Button;
	    int           X;
	    int           Y;
	} sfMouseButtonEvent;

	typedef struct sfMouseWheelEvent {
	    sfEventType Type;
	    int         Delta;
	    int         X;
	    int         Y;
	} sfMouseWheelEvent;

	typedef struct sfJoyMoveEvent {
	    sfEventType  Type;
	    unsigned int JoystickId;
	    sfJoyAxis    Axis;
	    float        Position;
	} sfJoyMoveEvent;

	typedef struct sfJoyButtonEvent	{
	    sfEventType  Type;
	    unsigned int JoystickId;
	    unsigned int Button;
	} sfJoyButtonEvent;

	typedef struct sfSizeEvent
	{
	    sfEventType  Type;
	    unsigned int Width;
	    unsigned int Height;
	} sfSizeEvent;

	typedef union sfEvent {
	    sfEventType               Type; ///< Type of the event
	    struct sfKeyEvent         Key;
	    struct sfTextEvent        Text;
	    struct sfMouseMoveEvent   MouseMove;
	    struct sfMouseButtonEvent MouseButton;
	    struct sfMouseWheelEvent  MouseWheel;
	    struct sfJoyMoveEvent     JoyMove;
	    struct sfJoyButtonEvent   JoyButton;
	    struct sfSizeEvent        Size;
	} sfEvent;
	
	typedef enum {
	    sfStopped, 
	    sfPaused,
	    sfPlaying
	} sfSoundStatus;

	CSFML_API void      sfSleep(sfUint32 duration);
	CSFML_API sfClock*  sfClock_Create(void);
	CSFML_API sfClock*  sfClock_Copy(sfClock* clock);
	CSFML_API void      sfClock_Destroy(sfClock* clock);
	CSFML_API sfUint32  sfClock_GetTime(const sfClock* clock);
	CSFML_API void      sfClock_Reset(sfClock* clock);
	CSFML_API sfMutex*  sfMutex_Create(void);
	CSFML_API void      sfMutex_Destroy(sfMutex* mutex);
	CSFML_API void      sfMutex_Lock(sfMutex* mutex);
	CSFML_API void      sfMutex_Unlock(sfMutex* mutex);
	CSFML_API sfThread* sfThread_Create(void (*function)(void*), void* userData);
	CSFML_API void      sfThread_Destroy(sfThread* thread);
	CSFML_API void      sfThread_Launch(sfThread* thread);
	CSFML_API void      sfThread_Wait(sfThread* thread);
	CSFML_API void      sfThread_Terminate(sfThread* thread);

	CSFML_API sfContext*             sfContext_Create(void);
	CSFML_API void                   sfContext_Destroy(sfContext* context);
	CSFML_API void                   sfContext_SetActive(sfContext* context, sfBool active);

	CSFML_API sfBool                 sfInput_IsKeyDown(const sfInput* input, sfKeyCode code);
	CSFML_API sfBool                 sfInput_IsMouseButtonDown(const sfInput* input, sfMouseButton button);
	CSFML_API sfBool                 sfInput_IsJoystickButtonDown(const sfInput* input, unsigned int joyId, unsigned int button);
	CSFML_API int                    sfInput_GetMouseX(const sfInput* input);
	CSFML_API int                    sfInput_GetMouseY(const sfInput* input);
	CSFML_API float                  sfInput_GetJoystickAxis(const sfInput* input, unsigned int joyId, sfJoyAxis axis);	

	CSFML_API sfVideoMode            sfVideoMode_GetDesktopMode(void);
	CSFML_API const sfVideoMode*     sfVideoMode_GetFullscreenModes(size_t* Count);
	CSFML_API sfBool                 sfVideoMode_IsValid(sfVideoMode mode);

	enum
	{
	    sfNone         = 0,      ///< No border / title bar (this flag and all others are mutually exclusive)
	    sfTitlebar     = 1 << 0, ///< Title bar + fixed border
	    sfResize       = 1 << 1, ///< Titlebar + resizable border + maximize button
	    sfClose        = 1 << 2, ///< Titlebar + close button
	    sfFullscreen   = 1 << 3, ///< Fullscreen mode (this flag and all others are mutually exclusive)
	    sfDefaultStyle = sfTitlebar | sfResize | sfClose ///< Default window style
	};

	typedef struct sfContextSettings {
	    unsigned int DepthBits;         ///< Bits of the depth buffer
	    unsigned int StencilBits;       ///< Bits of the stencil buffer
	    unsigned int AntialiasingLevel; ///< Level of antialiasing
	    unsigned int MajorVersion;      ///< Major number of the context version to create
	    unsigned int MinorVersion;      ///< Minor number of the context version to create
	} sfContextSettings;

	CSFML_API sfWindow*              sfWindow_Create(sfVideoMode mode, const char* title, unsigned long style, const sfContextSettings* settings);
	CSFML_API sfWindow*              sfWindow_CreateFromHandle(sfWindowHandle handle, const sfContextSettings* settings);
	CSFML_API void                   sfWindow_Destroy(sfWindow* window);
	CSFML_API void                   sfWindow_Close(sfWindow* window);
	CSFML_API sfBool                 sfWindow_IsOpened(const sfWindow* window);
	CSFML_API unsigned int           sfWindow_GetWidth(const sfWindow* window);
	CSFML_API unsigned int           sfWindow_GetHeight(const sfWindow* window);
	CSFML_API sfContextSettings      sfWindow_GetSettings(const sfWindow* window);
	CSFML_API sfBool                 sfWindow_PollEvent(sfWindow* window, sfEvent* event);
	CSFML_API sfBool                 sfWindow_WaitEvent(sfWindow* window, sfEvent* event);
	CSFML_API void                   sfWindow_EnableVerticalSync(sfWindow* window, sfBool enabled);
	CSFML_API void                   sfWindow_ShowMouseCursor(sfWindow* window, sfBool show);
	CSFML_API void                   sfWindow_SetCursorPosition(sfWindow* window, unsigned int left, unsigned int Top);
	CSFML_API void                   sfWindow_SetPosition(sfWindow* window, int left, int top);
	CSFML_API void                   sfWindow_SetSize(sfWindow* window, unsigned int width, unsigned int height);
	CSFML_API void                   sfWindow_SetTitle(sfWindow* window, const char* title);
	CSFML_API void                   sfWindow_Show(sfWindow* window, sfBool show);
	CSFML_API void                   sfWindow_EnableKeyRepeat(sfWindow* window, sfBool enabled);
	CSFML_API void                   sfWindow_SetIcon(sfWindow* window, unsigned int width, unsigned int height, const sfUint8* pixels);
	CSFML_API sfBool                 sfWindow_SetActive(sfWindow* window, sfBool active);
	CSFML_API void                   sfWindow_Display(sfWindow* window);
	CSFML_API const sfInput*         sfWindow_GetInput(sfWindow* window);
	CSFML_API void                   sfWindow_SetFramerateLimit(sfWindow* window, unsigned int limit);
	CSFML_API sfUint32               sfWindow_GetFrameTime(const sfWindow* window);
	CSFML_API void                   sfWindow_SetJoystickThreshold(sfWindow* window, float threshold);
	CSFML_API sfWindowHandle         sfWindow_GetSystemHandle(const sfWindow* window);
	
	CSFML_API void                   sfListener_SetGlobalVolume(float volume);
	CSFML_API float                  sfListener_GetGlobalVolume(void);
	CSFML_API void                   sfListener_SetPosition(float x, float y, float z);
	CSFML_API void                   sfListener_GetPosition(float* x, float* y, float* z);
	CSFML_API void                   sfListener_SetDirection(float x, float y, float z);
	CSFML_API void                   sfListener_GetDirection(float* x, float* y, float* z);
                                        
	CSFML_API sfMusic*               sfMusic_CreateFromFile(const char* filename);
	CSFML_API sfMusic*               sfMusic_CreateFromMemory(const void* data, size_t sizeInBytes);
	CSFML_API void                   sfMusic_Destroy(sfMusic* music);
	CSFML_API void                   sfMusic_SetLoop(sfMusic* music, sfBool loop);
	CSFML_API sfBool                 sfMusic_GetLoop(const sfMusic* music);
	CSFML_API sfUint32               sfMusic_GetDuration(const sfMusic* music);
	CSFML_API void                   sfMusic_Play(sfMusic* music);
	CSFML_API void                   sfMusic_Pause(sfMusic* music);
	CSFML_API void                   sfMusic_Stop(sfMusic* music);
	CSFML_API unsigned int           sfMusic_GetChannelsCount(const sfMusic* music);
	CSFML_API unsigned int           sfMusic_GetSampleRate(const sfMusic* music);
	CSFML_API sfSoundStatus          sfMusic_GetStatus(const sfMusic* music);
	CSFML_API sfUint32               sfMusic_GetPlayingOffset(const sfMusic* music);
	CSFML_API void                   sfMusic_SetPitch(sfMusic* music, float pitch);
	CSFML_API void                   sfMusic_SetVolume(sfMusic* music, float volume);
	CSFML_API void                   sfMusic_SetPosition(sfMusic* music, float x, float y, float z);
	CSFML_API void                   sfMusic_SetRelativeToListener(sfMusic* music, sfBool relative);
	CSFML_API void                   sfMusic_SetMinDistance(sfMusic* music, float distance);
	CSFML_API void                   sfMusic_SetAttenuation(sfMusic* music, float attenuation);
	CSFML_API void                   sfMusic_SetPlayingOffset(sfMusic* music, sfUint32 timeOffset);
	CSFML_API float                  sfMusic_GetPitch(const sfMusic* music);
	CSFML_API float                  sfMusic_GetVolume(const sfMusic* music);
	CSFML_API void                   sfMusic_GetPosition(const sfMusic* music, float* x, float* y, float* z);
	CSFML_API sfBool                 sfMusic_IsRelativeToListener(const sfMusic* music);
	CSFML_API float                  sfMusic_GetMinDistance(const sfMusic* music);
	CSFML_API float                  sfMusic_GetAttenuation(const sfMusic* music);
                                        
	CSFML_API sfSound*               sfSound_Create(void);
	CSFML_API sfSound*               sfSound_Copy(sfSound* sound);
	CSFML_API void                   sfSound_Destroy(sfSound* sound);
	CSFML_API void                   sfSound_Play(sfSound* sound);
	CSFML_API void                   sfSound_Pause(sfSound* sound);
	CSFML_API void                   sfSound_Stop(sfSound* sound);
	CSFML_API void                   sfSound_SetBuffer(sfSound* sound, const sfSoundBuffer* buffer);
	CSFML_API const sfSoundBuffer*   sfSound_GetBuffer(const sfSound* sound);
	CSFML_API void                   sfSound_SetLoop(sfSound* sound, sfBool loop);
	CSFML_API sfBool                 sfSound_GetLoop(const sfSound* sound);
	CSFML_API sfSoundStatus          sfSound_GetStatus(const sfSound* sound);
	CSFML_API void                   sfSound_SetPitch(sfSound* sound, float pitch);
	CSFML_API void                   sfSound_SetVolume(sfSound* sound, float volume);
	CSFML_API void                   sfSound_SetPosition(sfSound* sound, float x, float y, float z);
	CSFML_API void                   sfSound_SetRelativeToListener(sfSound* sound, sfBool relative);
	CSFML_API void                   sfSound_SetMinDistance(sfSound* sound, float distance);
	CSFML_API void                   sfSound_SetAttenuation(sfSound* sound, float attenuation);
	CSFML_API void                   sfSound_SetPlayingOffset(sfSound* sound, sfUint32 timeOffset);
	CSFML_API float                  sfSound_GetPitch(const sfSound* sound);
	CSFML_API float                  sfSound_GetVolume(const sfSound* sound);
	CSFML_API void                   sfSound_GetPosition(const sfSound* sound, float* x, float* y, float* z);
	CSFML_API sfBool                 sfSound_IsRelativeToListener(const sfSound* sound);
	CSFML_API float                  sfSound_GetMinDistance(const sfSound* sound);
	CSFML_API float                  sfSound_GetAttenuation(const sfSound* sound);
	CSFML_API sfUint32               sfSound_GetPlayingOffset(const sfSound* sound);
                                        
	CSFML_API sfSoundBuffer*         sfSoundBuffer_CreateFromFile(const char* filename);
	CSFML_API sfSoundBuffer*         sfSoundBuffer_CreateFromMemory(const void* data, size_t sizeInBytes);
	CSFML_API sfSoundBuffer*         sfSoundBuffer_CreateFromSamples(const sfInt16* samples, size_t samplesCount, unsigned int channelsCount, unsigned int sampleRate);
	CSFML_API sfSoundBuffer*         sfSoundBuffer_Copy(sfSoundBuffer* soundBuffer);
	CSFML_API void                   sfSoundBuffer_Destroy(sfSoundBuffer* soundBuffer);
	CSFML_API sfBool                 sfSoundBuffer_SaveToFile(const sfSoundBuffer* soundBuffer, const char* filename);
	CSFML_API const sfInt16*         sfSoundBuffer_GetSamples(const sfSoundBuffer* soundBuffer);
	CSFML_API size_t                 sfSoundBuffer_GetSamplesCount(const sfSoundBuffer* soundBuffer);
	CSFML_API unsigned int           sfSoundBuffer_GetSampleRate(const sfSoundBuffer* soundBuffer);
	CSFML_API unsigned int           sfSoundBuffer_GetChannelsCount(const sfSoundBuffer* soundBuffer);
	CSFML_API sfUint32               sfSoundBuffer_GetDuration(const sfSoundBuffer* soundBuffer);
	                                
	CSFML_API sfSoundBufferRecorder* sfSoundBufferRecorder_Create(void);
	CSFML_API void                   sfSoundBufferRecorder_Destroy(sfSoundBufferRecorder* soundBufferRecorder);
	CSFML_API void                   sfSoundBufferRecorder_Start(sfSoundBufferRecorder* soundBufferRecorder, unsigned int sampleRate);
	CSFML_API void                   sfSoundBufferRecorder_Stop(sfSoundBufferRecorder* soundBufferRecorder);
	CSFML_API unsigned int           sfSoundBufferRecorder_GetSampleRate(const sfSoundBufferRecorder* soundBufferRecorder);
	CSFML_API const sfSoundBuffer*   sfSoundBufferRecorder_GetBuffer(const sfSoundBufferRecorder* soundBufferRecorder);
	

typedef sfBool (*sfSoundRecorderStartCallback)(void*);                           ///< Type of the callback used when starting a capture
typedef sfBool (*sfSoundRecorderProcessCallback)(const sfInt16*, size_t, void*); ///< Type of the callback used to process audio data
typedef void   (*sfSoundRecorderStopCallback)(void*);                            ///< Type of the callback used when stopping a capture

	CSFML_API sfSoundRecorder* sfSoundRecorder_Create(sfSoundRecorderStartCallback   onStart,
							sfSoundRecorderProcessCallback onProcess,
							sfSoundRecorderStopCallback    onStop,
							void*                          userData);
	CSFML_API void sfSoundRecorder_Destroy(sfSoundRecorder* soundRecorder);
	CSFML_API void sfSoundRecorder_Start(sfSoundRecorder* soundRecorder, unsigned int sampleRate);
	CSFML_API void sfSoundRecorder_Stop(sfSoundRecorder* soundRecorder);
	CSFML_API unsigned int sfSoundRecorder_GetSampleRate(const sfSoundRecorder* soundRecorder);
	CSFML_API sfBool sfSoundRecorder_IsAvailable(void);
	
typedef struct
{
    sfInt16*     Samples;   ///< Pointer to the audio samples
    unsigned int NbSamples; ///< Number of samples pointed by Samples
} sfSoundStreamChunk;

typedef sfBool (*sfSoundStreamGetDataCallback)(sfSoundStreamChunk*, void*); ///< Type of the callback used to get a sound stream data
typedef void   (*sfSoundStreamSeekCallback)(sfUint32, void*);               ///< Type of the callback used to seek in a sound stream

CSFML_API sfSoundStream* sfSoundStream_Create(sfSoundStreamGetDataCallback onGetData,
                                              sfSoundStreamSeekCallback    onSeek,
                                              unsigned int                 channelsCount,
                                              unsigned int                 sampleRate,
                                              void*                        userData);

	CSFML_API void sfSoundStream_Destroy(sfSoundStream* soundStream);
	CSFML_API void sfSoundStream_Play(sfSoundStream* soundStream);
	CSFML_API void sfSoundStream_Pause(sfSoundStream* soundStream);
	CSFML_API void sfSoundStream_Stop(sfSoundStream* soundStream);
	CSFML_API sfSoundStatus sfSoundStream_GetStatus(const sfSoundStream* soundStream);
	CSFML_API unsigned int sfSoundStream_GetChannelsCount(const sfSoundStream* soundStream);
	CSFML_API unsigned int sfSoundStream_GetSampleRate(const sfSoundStream* soundStream);
	CSFML_API void sfSoundStream_SetPitch(sfSoundStream* soundStream, float pitch);
	CSFML_API void sfSoundStream_SetVolume(sfSoundStream* soundStream, float volume);
	CSFML_API void sfSoundStream_SetPosition(sfSoundStream* soundStream, float x, float y, float z);
	CSFML_API void sfSoundStream_SetRelativeToListener(sfSoundStream* soundStream, sfBool relative);
	CSFML_API void sfSoundStream_SetMinDistance(sfSoundStream* soundStream, float distance);
	CSFML_API void sfSoundStream_SetAttenuation(sfSoundStream* soundStream, float attenuation);
	CSFML_API void sfSoundStream_SetPlayingOffset(sfSoundStream* soundStream, sfUint32 timeOffset);
	CSFML_API void sfSoundStream_SetLoop(sfSoundStream* soundStream, sfBool loop);
	CSFML_API float sfSoundStream_GetPitch(const sfSoundStream* soundStream);
	CSFML_API float sfSoundStream_GetVolume(const sfSoundStream* soundStream);
	CSFML_API void sfSoundStream_GetPosition(const sfSoundStream* soundStream, float* x, float* y, float* z);
	CSFML_API sfBool sfSoundStream_IsRelativeToListener(const sfSoundStream* soundStream);
	CSFML_API float sfSoundStream_GetMinDistance(const sfSoundStream* soundStream);
	CSFML_API float sfSoundStream_GetAttenuation(const sfSoundStream* soundStream);
	CSFML_API sfBool sfSoundStream_GetLoop(const sfSoundStream* soundStream);
	CSFML_API sfUint32 sfSoundStream_GetPlayingOffset(const sfSoundStream* soundStream);
]]
