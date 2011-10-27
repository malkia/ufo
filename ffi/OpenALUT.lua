local ffi = require 'ffi'
local al = require 'openal'
local alut = ffi.load 'alut'

ffi.cdef[[
enum {
  ALUT_API_MAJOR_VERSION = 1,
  ALUT_API_MINOR_VERSION = 1,
  ALUT_ERROR_NO_ERROR = 0,
  ALUT_ERROR_OUT_OF_MEMORY = 0x200,
  ALUT_ERROR_INVALID_ENUM = 0x201,
  ALUT_ERROR_INVALID_VALUE = 0x202,
  ALUT_ERROR_INVALID_OPERATION = 0x203,
  ALUT_ERROR_NO_CURRENT_CONTEXT = 0x204,
  ALUT_ERROR_AL_ERROR_ON_ENTRY = 0x205,
  ALUT_ERROR_ALC_ERROR_ON_ENTRY = 0x206,
  ALUT_ERROR_OPEN_DEVICE = 0x207,
  ALUT_ERROR_CLOSE_DEVICE = 0x208,
  ALUT_ERROR_CREATE_CONTEXT = 0x209,
  ALUT_ERROR_MAKE_CONTEXT_CURRENT = 0x20A,
  ALUT_ERROR_DESTROY_CONTEXT = 0x20B,
  ALUT_ERROR_GEN_BUFFERS = 0x20C,
  ALUT_ERROR_BUFFER_DATA = 0x20D,
  ALUT_ERROR_IO_ERROR = 0x20E,
  ALUT_ERROR_UNSUPPORTED_FILE_TYPE = 0x20F,
  ALUT_ERROR_UNSUPPORTED_FILE_SUBTYPE = 0x210,
  ALUT_ERROR_CORRUPT_OR_TRUNCATED_DATA = 0x211,
  ALUT_WAVEFORM_SINE = 0x100,
  ALUT_WAVEFORM_SQUARE = 0x101,
  ALUT_WAVEFORM_SAWTOOTH = 0x102,
  ALUT_WAVEFORM_WHITENOISE = 0x103,
  ALUT_WAVEFORM_IMPULSE = 0x104,
  ALUT_LOADER_BUFFER = 0x300,
  ALUT_LOADER_MEMORY = 0x301,
};
ALboolean alutInit (int *argcp, char **argv);
ALboolean alutInitWithoutContext (int *argcp, char **argv);
ALboolean alutExit (void);
ALenum alutGetError (void);
const char *alutGetErrorString (ALenum error);
ALuint alutCreateBufferFromFile (const char *fileName);
ALuint alutCreateBufferFromFileImage (const ALvoid *data, ALsizei length);
ALuint alutCreateBufferHelloWorld (void);
ALuint alutCreateBufferWaveform (ALenum waveshape, ALfloat frequency, ALfloat phase, ALfloat duration);
ALvoid *alutLoadMemoryFromFile (const char *fileName, ALenum *format, ALsizei *size, ALfloat *frequency);
ALvoid *alutLoadMemoryFromFileImage (const ALvoid *data, ALsizei length, ALenum *format, ALsizei *size, ALfloat *frequency);
ALvoid *alutLoadMemoryHelloWorld (ALenum *format, ALsizei *size, ALfloat *frequency);
ALvoid *alutLoadMemoryWaveform (ALenum waveshape, ALfloat frequency, ALfloat phase, ALfloat duration, ALenum *format, ALsizei *size, ALfloat *freq);
const char *alutGetMIMETypes (ALenum loader);
ALint alutGetMajorVersion (void);
ALint alutGetMinorVersion (void);
ALboolean alutSleep (ALfloat duration);
]]

return alut
