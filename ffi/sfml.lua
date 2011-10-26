local ffi = require( "ffi" )
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

	void      sfSleep(sfUint32 duration);
	sfClock*  sfClock_Create(void);
	sfClock*  sfClock_Copy(sfClock* clock);
	void      sfClock_Destroy(sfClock* clock);
	sfUint32  sfClock_GetTime(const sfClock* clock);
	void      sfClock_Reset(sfClock* clock);
	sfMutex*  sfMutex_Create(void);
	void      sfMutex_Destroy(sfMutex* mutex);
	void      sfMutex_Lock(sfMutex* mutex);
	void      sfMutex_Unlock(sfMutex* mutex);
	sfThread* sfThread_Create(void (*function)(void*), void* userData);
	void      sfThread_Destroy(sfThread* thread);
	void      sfThread_Launch(sfThread* thread);
	void      sfThread_Wait(sfThread* thread);
	void      sfThread_Terminate(sfThread* thread);

	sfContext*             sfContext_Create(void);
	void                   sfContext_Destroy(sfContext* context);
	void                   sfContext_SetActive(sfContext* context, sfBool active);

	sfBool                 sfInput_IsKeyDown(const sfInput* input, sfKeyCode code);
	sfBool                 sfInput_IsMouseButtonDown(const sfInput* input, sfMouseButton button);
	sfBool                 sfInput_IsJoystickButtonDown(const sfInput* input, unsigned int joyId, unsigned int button);
	int                    sfInput_GetMouseX(const sfInput* input);
	int                    sfInput_GetMouseY(const sfInput* input);
	float                  sfInput_GetJoystickAxis(const sfInput* input, unsigned int joyId, sfJoyAxis axis);	

	sfVideoMode            sfVideoMode_GetDesktopMode(void);
	const sfVideoMode*     sfVideoMode_GetFullscreenModes(size_t* Count);
	sfBool                 sfVideoMode_IsValid(sfVideoMode mode);

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

	sfWindow*              sfWindow_Create(sfVideoMode mode, const char* title, unsigned long style, const sfContextSettings* settings);
	sfWindow*              sfWindow_CreateFromHandle(sfWindowHandle handle, const sfContextSettings* settings);
	void                   sfWindow_Destroy(sfWindow* window);
	void                   sfWindow_Close(sfWindow* window);
	sfBool                 sfWindow_IsOpened(const sfWindow* window);
	unsigned int           sfWindow_GetWidth(const sfWindow* window);
	unsigned int           sfWindow_GetHeight(const sfWindow* window);
	sfContextSettings      sfWindow_GetSettings(const sfWindow* window);
	sfBool                 sfWindow_PollEvent(sfWindow* window, sfEvent* event);
	sfBool                 sfWindow_WaitEvent(sfWindow* window, sfEvent* event);
	void                   sfWindow_EnableVerticalSync(sfWindow* window, sfBool enabled);
	void                   sfWindow_ShowMouseCursor(sfWindow* window, sfBool show);
	void                   sfWindow_SetCursorPosition(sfWindow* window, unsigned int left, unsigned int Top);
	void                   sfWindow_SetPosition(sfWindow* window, int left, int top);
	void                   sfWindow_SetSize(sfWindow* window, unsigned int width, unsigned int height);
	void                   sfWindow_SetTitle(sfWindow* window, const char* title);
	void                   sfWindow_Show(sfWindow* window, sfBool show);
	void                   sfWindow_EnableKeyRepeat(sfWindow* window, sfBool enabled);
	void                   sfWindow_SetIcon(sfWindow* window, unsigned int width, unsigned int height, const sfUint8* pixels);
	sfBool                 sfWindow_SetActive(sfWindow* window, sfBool active);
	void                   sfWindow_Display(sfWindow* window);
	const sfInput*         sfWindow_GetInput(sfWindow* window);
	void                   sfWindow_SetFramerateLimit(sfWindow* window, unsigned int limit);
	sfUint32               sfWindow_GetFrameTime(const sfWindow* window);
	void                   sfWindow_SetJoystickThreshold(sfWindow* window, float threshold);
	sfWindowHandle         sfWindow_GetSystemHandle(const sfWindow* window);
	
	void                   sfListener_SetGlobalVolume(float volume);
	float                  sfListener_GetGlobalVolume(void);
	void                   sfListener_SetPosition(float x, float y, float z);
	void                   sfListener_GetPosition(float* x, float* y, float* z);
	void                   sfListener_SetDirection(float x, float y, float z);
	void                   sfListener_GetDirection(float* x, float* y, float* z);
                                        
	sfMusic*               sfMusic_CreateFromFile(const char* filename);
	sfMusic*               sfMusic_CreateFromMemory(const void* data, size_t sizeInBytes);
	void                   sfMusic_Destroy(sfMusic* music);
	void                   sfMusic_SetLoop(sfMusic* music, sfBool loop);
	sfBool                 sfMusic_GetLoop(const sfMusic* music);
	sfUint32               sfMusic_GetDuration(const sfMusic* music);
	void                   sfMusic_Play(sfMusic* music);
	void                   sfMusic_Pause(sfMusic* music);
	void                   sfMusic_Stop(sfMusic* music);
	unsigned int           sfMusic_GetChannelsCount(const sfMusic* music);
	unsigned int           sfMusic_GetSampleRate(const sfMusic* music);
	sfSoundStatus          sfMusic_GetStatus(const sfMusic* music);
	sfUint32               sfMusic_GetPlayingOffset(const sfMusic* music);
	void                   sfMusic_SetPitch(sfMusic* music, float pitch);
	void                   sfMusic_SetVolume(sfMusic* music, float volume);
	void                   sfMusic_SetPosition(sfMusic* music, float x, float y, float z);
	void                   sfMusic_SetRelativeToListener(sfMusic* music, sfBool relative);
	void                   sfMusic_SetMinDistance(sfMusic* music, float distance);
	void                   sfMusic_SetAttenuation(sfMusic* music, float attenuation);
	void                   sfMusic_SetPlayingOffset(sfMusic* music, sfUint32 timeOffset);
	float                  sfMusic_GetPitch(const sfMusic* music);
	float                  sfMusic_GetVolume(const sfMusic* music);
	void                   sfMusic_GetPosition(const sfMusic* music, float* x, float* y, float* z);
	sfBool                 sfMusic_IsRelativeToListener(const sfMusic* music);
	float                  sfMusic_GetMinDistance(const sfMusic* music);
	float                  sfMusic_GetAttenuation(const sfMusic* music);
                                        
	sfSound*               sfSound_Create(void);
	sfSound*               sfSound_Copy(sfSound* sound);
	void                   sfSound_Destroy(sfSound* sound);
	void                   sfSound_Play(sfSound* sound);
	void                   sfSound_Pause(sfSound* sound);
	void                   sfSound_Stop(sfSound* sound);
	void                   sfSound_SetBuffer(sfSound* sound, const sfSoundBuffer* buffer);
	const sfSoundBuffer*   sfSound_GetBuffer(const sfSound* sound);
	void                   sfSound_SetLoop(sfSound* sound, sfBool loop);
	sfBool                 sfSound_GetLoop(const sfSound* sound);
	sfSoundStatus          sfSound_GetStatus(const sfSound* sound);
	void                   sfSound_SetPitch(sfSound* sound, float pitch);
	void                   sfSound_SetVolume(sfSound* sound, float volume);
	void                   sfSound_SetPosition(sfSound* sound, float x, float y, float z);
	void                   sfSound_SetRelativeToListener(sfSound* sound, sfBool relative);
	void                   sfSound_SetMinDistance(sfSound* sound, float distance);
	void                   sfSound_SetAttenuation(sfSound* sound, float attenuation);
	void                   sfSound_SetPlayingOffset(sfSound* sound, sfUint32 timeOffset);
	float                  sfSound_GetPitch(const sfSound* sound);
	float                  sfSound_GetVolume(const sfSound* sound);
	void                   sfSound_GetPosition(const sfSound* sound, float* x, float* y, float* z);
	sfBool                 sfSound_IsRelativeToListener(const sfSound* sound);
	float                  sfSound_GetMinDistance(const sfSound* sound);
	float                  sfSound_GetAttenuation(const sfSound* sound);
	sfUint32               sfSound_GetPlayingOffset(const sfSound* sound);
                                        
	sfSoundBuffer*         sfSoundBuffer_CreateFromFile(const char* filename);
	sfSoundBuffer*         sfSoundBuffer_CreateFromMemory(const void* data, size_t sizeInBytes);
	sfSoundBuffer*         sfSoundBuffer_CreateFromSamples(const sfInt16* samples, size_t samplesCount, unsigned int channelsCount, unsigned int sampleRate);
	sfSoundBuffer*         sfSoundBuffer_Copy(sfSoundBuffer* soundBuffer);
	void                   sfSoundBuffer_Destroy(sfSoundBuffer* soundBuffer);
	sfBool                 sfSoundBuffer_SaveToFile(const sfSoundBuffer* soundBuffer, const char* filename);
	const sfInt16*         sfSoundBuffer_GetSamples(const sfSoundBuffer* soundBuffer);
	size_t                 sfSoundBuffer_GetSamplesCount(const sfSoundBuffer* soundBuffer);
	unsigned int           sfSoundBuffer_GetSampleRate(const sfSoundBuffer* soundBuffer);
	unsigned int           sfSoundBuffer_GetChannelsCount(const sfSoundBuffer* soundBuffer);
	sfUint32               sfSoundBuffer_GetDuration(const sfSoundBuffer* soundBuffer);
	                                
	sfSoundBufferRecorder* sfSoundBufferRecorder_Create(void);
	void                   sfSoundBufferRecorder_Destroy(sfSoundBufferRecorder* soundBufferRecorder);
	void                   sfSoundBufferRecorder_Start(sfSoundBufferRecorder* soundBufferRecorder, unsigned int sampleRate);
	void                   sfSoundBufferRecorder_Stop(sfSoundBufferRecorder* soundBufferRecorder);
	unsigned int           sfSoundBufferRecorder_GetSampleRate(const sfSoundBufferRecorder* soundBufferRecorder);
	const sfSoundBuffer*   sfSoundBufferRecorder_GetBuffer(const sfSoundBufferRecorder* soundBufferRecorder);
	

typedef sfBool (*sfSoundRecorderStartCallback)(void*);                           ///< Type of the callback used when starting a capture
typedef sfBool (*sfSoundRecorderProcessCallback)(const sfInt16*, size_t, void*); ///< Type of the callback used to process audio data
typedef void   (*sfSoundRecorderStopCallback)(void*);                            ///< Type of the callback used when stopping a capture

	sfSoundRecorder* sfSoundRecorder_Create(sfSoundRecorderStartCallback   onStart,
							sfSoundRecorderProcessCallback onProcess,
							sfSoundRecorderStopCallback    onStop,
							void*                          userData);
	void sfSoundRecorder_Destroy(sfSoundRecorder* soundRecorder);
	void sfSoundRecorder_Start(sfSoundRecorder* soundRecorder, unsigned int sampleRate);
	void sfSoundRecorder_Stop(sfSoundRecorder* soundRecorder);
	unsigned int sfSoundRecorder_GetSampleRate(const sfSoundRecorder* soundRecorder);
	sfBool sfSoundRecorder_IsAvailable(void);
	
typedef struct
{
    sfInt16*     Samples;   ///< Pointer to the audio samples
    unsigned int NbSamples; ///< Number of samples pointed by Samples
} sfSoundStreamChunk;

typedef sfBool (*sfSoundStreamGetDataCallback)(sfSoundStreamChunk*, void*); ///< Type of the callback used to get a sound stream data
typedef void   (*sfSoundStreamSeekCallback)(sfUint32, void*);               ///< Type of the callback used to seek in a sound stream

sfSoundStream* sfSoundStream_Create(sfSoundStreamGetDataCallback onGetData,
                                              sfSoundStreamSeekCallback    onSeek,
                                              unsigned int                 channelsCount,
                                              unsigned int                 sampleRate,
                                              void*                        userData);

	void sfSoundStream_Destroy(sfSoundStream* soundStream);
	void sfSoundStream_Play(sfSoundStream* soundStream);
	void sfSoundStream_Pause(sfSoundStream* soundStream);
	void sfSoundStream_Stop(sfSoundStream* soundStream);
	sfSoundStatus sfSoundStream_GetStatus(const sfSoundStream* soundStream);
	unsigned int sfSoundStream_GetChannelsCount(const sfSoundStream* soundStream);
	unsigned int sfSoundStream_GetSampleRate(const sfSoundStream* soundStream);
	void sfSoundStream_SetPitch(sfSoundStream* soundStream, float pitch);
	void sfSoundStream_SetVolume(sfSoundStream* soundStream, float volume);
	void sfSoundStream_SetPosition(sfSoundStream* soundStream, float x, float y, float z);
	void sfSoundStream_SetRelativeToListener(sfSoundStream* soundStream, sfBool relative);
	void sfSoundStream_SetMinDistance(sfSoundStream* soundStream, float distance);
	void sfSoundStream_SetAttenuation(sfSoundStream* soundStream, float attenuation);
	void sfSoundStream_SetPlayingOffset(sfSoundStream* soundStream, sfUint32 timeOffset);
	void sfSoundStream_SetLoop(sfSoundStream* soundStream, sfBool loop);
	float sfSoundStream_GetPitch(const sfSoundStream* soundStream);
	float sfSoundStream_GetVolume(const sfSoundStream* soundStream);
	void sfSoundStream_GetPosition(const sfSoundStream* soundStream, float* x, float* y, float* z);
	sfBool sfSoundStream_IsRelativeToListener(const sfSoundStream* soundStream);
	float sfSoundStream_GetMinDistance(const sfSoundStream* soundStream);
	float sfSoundStream_GetAttenuation(const sfSoundStream* soundStream);
	sfBool sfSoundStream_GetLoop(const sfSoundStream* soundStream);
	sfUint32 sfSoundStream_GetPlayingOffset(const sfSoundStream* soundStream);
]]
