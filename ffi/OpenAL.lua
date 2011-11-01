-- The code below was contributed by David Hollander along with OpenALUT.cpp
-- To run on Windows, there are few choices, easiest one is to download
-- http://connect.creativelabs.com/openal/Downloads/oalinst.zip
-- and run the executable from inside of it (I've seen couple of games use it).

ffi = require 'ffi'
local al = ffi.load( ffi.os=="Windows" and "openal32" or "openal" )
ffi.cdef[[
typedef char ALboolean;         /** 8-bit boolean */
typedef char ALchar;            /** character */
typedef signed char ALbyte;     /** signed 8-bit 2's complement integer */
typedef unsigned char ALubyte;  /** unsigned 8-bit integer */
typedef short ALshort;          /** signed 16-bit 2's complement integer */
typedef unsigned short ALushort;/** unsigned 16-bit integer */
typedef int ALint;              /** signed 32-bit 2's complement integer */
typedef unsigned int ALuint;    /** unsigned 32-bit integer */
typedef int ALsizei;            /** non-negative 32-bit binary integer size */
typedef int ALenum;             /** enumerated 32-bit value */
typedef float ALfloat;          /** 32-bit IEEE754 floating-point */
typedef double ALdouble;        /** 64-bit IEEE754 floating-point */
typedef void ALvoid;            /** void type (for opaque pointers only) */
enum {
  AL_NONE = 0,
  AL_FALSE = 0,
  AL_TRUE = 1,
  AL_SOURCE_RELATIVE = 0x202,
  AL_CONE_INNER_ANGLE = 0x1001,
  AL_CONE_OUTER_ANGLE = 0x1002,
  AL_PITCH = 0x1003,
  AL_POSITION = 0x1004,
  AL_DIRECTION = 0x1005,
  AL_VELOCITY = 0x1006,
  AL_LOOPING = 0x1007,
  AL_BUFFER = 0x1009,
  AL_GAIN = 0x100A,
  AL_MIN_GAIN = 0x100D,
  AL_MAX_GAIN = 0x100E,
  AL_ORIENTATION = 0x100F,
  AL_SOURCE_STATE = 0x1010,
  AL_INITIAL = 0x1011,
  AL_PLAYING = 0x1012,
  AL_PAUSED = 0x1013,
  AL_STOPPED = 0x1014,
  AL_BUFFERS_QUEUED = 0x1015,
  AL_BUFFERS_PROCESSED = 0x1016,
  AL_SEC_OFFSET = 0x1024,
  AL_SAMPLE_OFFSET = 0x1025,
  AL_BYTE_OFFSET = 0x1026,
  AL_SOURCE_TYPE = 0x1027,
  AL_STATIC = 0x1028,
  AL_STREAMING = 0x1029,
  AL_UNDETERMINED = 0x1030,
  AL_FORMAT_MONO8 = 0x1100,
  AL_FORMAT_MONO16 = 0x1101,
  AL_FORMAT_STEREO8 = 0x1102,
  AL_FORMAT_STEREO16 = 0x1103,
  AL_REFERENCE_DISTANCE = 0x1020,
  AL_ROLLOFF_FACTOR = 0x1021,
  AL_CONE_OUTER_GAIN = 0x1022,
  AL_MAX_DISTANCE = 0x1023,
  AL_FREQUENCY = 0x2001,
  AL_BITS = 0x2002,
  AL_CHANNELS = 0x2003,
  AL_SIZE = 0x2004,
  AL_UNUSED = 0x2010,
  AL_PENDING = 0x2011,
  AL_PROCESSED = 0x2012,
  AL_NO_ERROR = 0,
  AL_INVALID_NAME = 0xA001,
  AL_INVALID_ENUM = 0xA002,
  AL_INVALID_VALUE = 0xA003,
  AL_INVALID_OPERATION = 0xA004,
  AL_OUT_OF_MEMORY = 0xA005,
  AL_VENDOR = 0xB001,
  AL_VERSION = 0xB002,
  AL_RENDERER = 0xB003,
  AL_EXTENSIONS = 0xB004,
  AL_DOPPLER_FACTOR = 0xC000,
  AL_DOPPLER_VELOCITY = 0xC001,
  AL_SPEED_OF_SOUND = 0xC003,
  AL_DISTANCE_MODEL = 0xD000,
  AL_INVERSE_DISTANCE = 0xD001,
  AL_INVERSE_DISTANCE_CLAMPED = 0xD002,
  AL_LINEAR_DISTANCE = 0xD003,
  AL_LINEAR_DISTANCE_CLAMPED = 0xD004,
  AL_EXPONENT_DISTANCE = 0xD005,
  AL_EXPONENT_DISTANCE_CLAMPED = 0xD006,
};
void alEnable( ALenum capability );
void alDisable( ALenum capability ); 
ALboolean alIsEnabled( ALenum capability ); 
const ALchar* alGetString( ALenum param );
void alGetBooleanv( ALenum param, ALboolean* data );
void alGetIntegerv( ALenum param, ALint* data );
void alGetFloatv( ALenum param, ALfloat* data );
void alGetDoublev( ALenum param, ALdouble* data );
ALboolean alGetBoolean( ALenum param );
ALint alGetInteger( ALenum param );
ALfloat alGetFloat( ALenum param );
ALdouble alGetDouble( ALenum param );
ALenum alGetError( void );
ALboolean alIsExtensionPresent( const ALchar* extname );
void* alGetProcAddress( const ALchar* fname );
ALenum alGetEnumValue( const ALchar* ename );
void alListenerf( ALenum param, ALfloat value );
void alListener3f( ALenum param, ALfloat value1, ALfloat value2, ALfloat value3 );
void alListenerfv( ALenum param, const ALfloat* values ); 
void alListeneri( ALenum param, ALint value );
void alListener3i( ALenum param, ALint value1, ALint value2, ALint value3 );
void alListeneriv( ALenum param, const ALint* values );
void alGetListenerf( ALenum param, ALfloat* value );
void alGetListener3f( ALenum param, ALfloat *value1, ALfloat *value2, ALfloat *value3 );
void alGetListenerfv( ALenum param, ALfloat* values );
void alGetListeneri( ALenum param, ALint* value );
void alGetListener3i( ALenum param, ALint *value1, ALint *value2, ALint *value3 );
void alGetListeneriv( ALenum param, ALint* values );
void alGenSources( ALsizei n, ALuint* sources ); 
void alDeleteSources( ALsizei n, const ALuint* sources );
ALboolean alIsSource( ALuint sid ); 
void alSourcef( ALuint sid, ALenum param, ALfloat value ); 
void alSource3f( ALuint sid, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3 );
void alSourcefv( ALuint sid, ALenum param, const ALfloat* values ); 
void alSourcei( ALuint sid, ALenum param, ALint value ); 
void alSource3i( ALuint sid, ALenum param, ALint value1, ALint value2, ALint value3 );
void alSourceiv( ALuint sid, ALenum param, const ALint* values );
void alGetSourcef( ALuint sid, ALenum param, ALfloat* value );
void alGetSource3f( ALuint sid, ALenum param, ALfloat* value1, ALfloat* value2, ALfloat* value3);
void alGetSourcefv( ALuint sid, ALenum param, ALfloat* values );
void alGetSourcei( ALuint sid,  ALenum param, ALint* value );
void alGetSource3i( ALuint sid, ALenum param, ALint* value1, ALint* value2, ALint* value3);
void alGetSourceiv( ALuint sid,  ALenum param, ALint* values );
void alSourcePlayv( ALsizei ns, const ALuint *sids );
void alSourceStopv( ALsizei ns, const ALuint *sids );
void alSourceRewindv( ALsizei ns, const ALuint *sids );
void alSourcePausev( ALsizei ns, const ALuint *sids );
void alSourcePlay( ALuint sid );
void alSourceStop( ALuint sid );
void alSourceRewind( ALuint sid );
void alSourcePause( ALuint sid );
void alSourceQueueBuffers( ALuint sid, ALsizei numEntries, const ALuint *bids );
void alSourceUnqueueBuffers( ALuint sid, ALsizei numEntries, ALuint *bids );
void alGenBuffers( ALsizei n, ALuint* buffers );
void alDeleteBuffers( ALsizei n, const ALuint* buffers );
ALboolean alIsBuffer( ALuint bid );
void alBufferData( ALuint bid, ALenum format, const ALvoid* data, ALsizei size, ALsizei freq );
void alBufferf( ALuint bid, ALenum param, ALfloat value );
void alBuffer3f( ALuint bid, ALenum param, ALfloat value1, ALfloat value2, ALfloat value3 );
void alBufferfv( ALuint bid, ALenum param, const ALfloat* values );
void alBufferi( ALuint bid, ALenum param, ALint value );
void alBuffer3i( ALuint bid, ALenum param, ALint value1, ALint value2, ALint value3 );
void alBufferiv( ALuint bid, ALenum param, const ALint* values );
void alGetBufferf( ALuint bid, ALenum param, ALfloat* value );
void alGetBuffer3f( ALuint bid, ALenum param, ALfloat* value1, ALfloat* value2, ALfloat* value3);
void alGetBufferfv( ALuint bid, ALenum param, ALfloat* values );
void alGetBufferi( ALuint bid, ALenum param, ALint* value );
void alGetBuffer3i( ALuint bid, ALenum param, ALint* value1, ALint* value2, ALint* value3);
void alGetBufferiv( ALuint bid, ALenum param, ALint* values );
void alDopplerFactor( ALfloat value );
void alDopplerVelocity( ALfloat value );
void alSpeedOfSound( ALfloat value );
void alDistanceModel( ALenum distanceModel );
]]

return al
