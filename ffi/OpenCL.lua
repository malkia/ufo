local ffi  = require( "ffi" )

local libs = ffi_OpenCL_libs or {
   OSX     = { x86 = "OpenCL.framework/OpenCL", x64 = "OpenCL.framework/OpenCL" },
   Windows = { x86 = "OPENCL.DLL",              x64 = "OPENCL.DLL"              },
   Linux   = { x86 = "libOpenCL.so",            x64 = "libOpenCL.so"            },
   BSD     = { x86 = "libOpenCL.so",            x64 = "libOpenCL.so"            },
   POSIX   = { x86 = "libOpenCL.so",            x64 = "libOpenCL.so"            },
   Other   = { x86 = "libOpenCL.so",            x64 = "libOpenCL.so"            },
}

local lib  = ffi_OpenCL_lib or libs[ ffi.os ][ ffi.arch ]

local cl   = ffi.load( lib )

ffi.cdef[[
enum {
  CL_SUCCESS                                   = 0,
  CL_DEVICE_NOT_FOUND                          = -1,
  CL_DEVICE_NOT_AVAILABLE                      = -2,
  CL_COMPILER_NOT_AVAILABLE                    = -3,
  CL_MEM_OBJECT_ALLOCATION_FAILURE             = -4,
  CL_OUT_OF_RESOURCES                          = -5,
  CL_OUT_OF_HOST_MEMORY                        = -6,
  CL_PROFILING_INFO_NOT_AVAILABLE              = -7,
  CL_MEM_COPY_OVERLAP                          = -8,
  CL_IMAGE_FORMAT_MISMATCH                     = -9,
  CL_IMAGE_FORMAT_NOT_SUPPORTED                = -10,
  CL_BUILD_PROGRAM_FAILURE                     = -11,
  CL_MAP_FAILURE                               = -12,
  CL_MISALIGNED_SUB_BUFFER_OFFSET              = -13,
  CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST = -14,
  CL_INVALID_VALUE                             = -30,
  CL_INVALID_DEVICE_TYPE                       = -31,
  CL_INVALID_PLATFORM                          = -32,
  CL_INVALID_DEVICE                            = -33,
  CL_INVALID_CONTEXT                           = -34,
  CL_INVALID_QUEUE_PROPERTIES                  = -35,
  CL_INVALID_COMMAND_QUEUE                     = -36,
  CL_INVALID_HOST_PTR                          = -37,
  CL_INVALID_MEM_OBJECT                        = -38,
  CL_INVALID_IMAGE_FORMAT_DESCRIPTOR           = -39,
  CL_INVALID_IMAGE_SIZE                        = -40,
  CL_INVALID_SAMPLER                           = -41,
  CL_INVALID_BINARY                            = -42,
  CL_INVALID_BUILD_OPTIONS                     = -43,
  CL_INVALID_PROGRAM                           = -44,
  CL_INVALID_PROGRAM_EXECUTABLE                = -45,
  CL_INVALID_KERNEL_NAME                       = -46,
  CL_INVALID_KERNEL_DEFINITION                 = -47,
  CL_INVALID_KERNEL                            = -48,
  CL_INVALID_ARG_INDEX                         = -49,
  CL_INVALID_ARG_VALUE                         = -50,
  CL_INVALID_ARG_SIZE                          = -51,
  CL_INVALID_KERNEL_ARGS                       = -52,
  CL_INVALID_WORK_DIMENSION                    = -53,
  CL_INVALID_WORK_GROUP_SIZE                   = -54,
  CL_INVALID_WORK_ITEM_SIZE                    = -55,
  CL_INVALID_GLOBAL_OFFSET                     = -56,
  CL_INVALID_EVENT_WAIT_LIST                   = -57,
  CL_INVALID_EVENT                             = -58,
  CL_INVALID_OPERATION                         = -59,
  CL_INVALID_GL_OBJECT                         = -60,
  CL_INVALID_BUFFER_SIZE                       = -61,
  CL_INVALID_MIP_LEVEL                         = -62,
  CL_INVALID_GLOBAL_WORK_SIZE                  = -63,
  CL_INVALID_PROPERTY                          = -64,
  CL_VERSION_1_0                               = 1,
  CL_VERSION_1_1                               = 1,
  CL_FALSE                                     = 0,
  CL_TRUE                                      = 1,
  CL_PLATFORM_PROFILE                          = 0x0900,
  CL_PLATFORM_VERSION                          = 0x0901,
  CL_PLATFORM_NAME                             = 0x0902,
  CL_PLATFORM_VENDOR                           = 0x0903,
  CL_PLATFORM_EXTENSIONS                       = 0x0904,
  CL_DEVICE_TYPE_DEFAULT                       = 0x01,
  CL_DEVICE_TYPE_CPU                           = 0x02,
  CL_DEVICE_TYPE_GPU                           = 0x04,
  CL_DEVICE_TYPE_ACCELERATOR                   = 0x08,
  CL_DEVICE_TYPE_ALL                           = 0xFFFFFFFF,
  CL_DEVICE_TYPE                               = 0x1000,
  CL_DEVICE_VENDOR_ID                          = 0x1001,
  CL_DEVICE_MAX_COMPUTE_UNITS                  = 0x1002,
  CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS           = 0x1003,
  CL_DEVICE_MAX_WORK_GROUP_SIZE                = 0x1004,
  CL_DEVICE_MAX_WORK_ITEM_SIZES                = 0x1005,
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR        = 0x1006,
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT       = 0x1007,
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT         = 0x1008,
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG        = 0x1009,
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT       = 0x100A,
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE      = 0x100B,
  CL_DEVICE_MAX_CLOCK_FREQUENCY                = 0x100C,
  CL_DEVICE_ADDRESS_BITS                       = 0x100D,
  CL_DEVICE_MAX_READ_IMAGE_ARGS                = 0x100E,
  CL_DEVICE_MAX_WRITE_IMAGE_ARGS               = 0x100F,
  CL_DEVICE_MAX_MEM_ALLOC_SIZE                 = 0x1010,
  CL_DEVICE_IMAGE2D_MAX_WIDTH                  = 0x1011,
  CL_DEVICE_IMAGE2D_MAX_HEIGHT                 = 0x1012,
  CL_DEVICE_IMAGE3D_MAX_WIDTH                  = 0x1013,
  CL_DEVICE_IMAGE3D_MAX_HEIGHT                 = 0x1014,
  CL_DEVICE_IMAGE3D_MAX_DEPTH                  = 0x1015,
  CL_DEVICE_IMAGE_SUPPORT                      = 0x1016,
  CL_DEVICE_MAX_PARAMETER_SIZE                 = 0x1017,
  CL_DEVICE_MAX_SAMPLERS                       = 0x1018,
  CL_DEVICE_MEM_BASE_ADDR_ALIGN                = 0x1019,
  CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE           = 0x101A,
  CL_DEVICE_SINGLE_FP_CONFIG                   = 0x101B,
  CL_DEVICE_GLOBAL_MEM_CACHE_TYPE              = 0x101C,
  CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE          = 0x101D,
  CL_DEVICE_GLOBAL_MEM_CACHE_SIZE              = 0x101E,
  CL_DEVICE_GLOBAL_MEM_SIZE                    = 0x101F,
  CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE           = 0x1020,
  CL_DEVICE_MAX_CONSTANT_ARGS                  = 0x1021,
  CL_DEVICE_LOCAL_MEM_TYPE                     = 0x1022,
  CL_DEVICE_LOCAL_MEM_SIZE                     = 0x1023,
  CL_DEVICE_ERROR_CORRECTION_SUPPORT           = 0x1024,
  CL_DEVICE_PROFILING_TIMER_RESOLUTION         = 0x1025,
  CL_DEVICE_ENDIAN_LITTLE                      = 0x1026,
  CL_DEVICE_AVAILABLE                          = 0x1027,
  CL_DEVICE_COMPILER_AVAILABLE                 = 0x1028,
  CL_DEVICE_EXECUTION_CAPABILITIES             = 0x1029,
  CL_DEVICE_QUEUE_PROPERTIES                   = 0x102A,
  CL_DEVICE_NAME                               = 0x102B,
  CL_DEVICE_VENDOR                             = 0x102C,
  CL_DRIVER_VERSION                            = 0x102D,
  CL_DEVICE_DRIVER_VERSION                     = CL_DRIVER_VERSION,
  CL_DEVICE_PROFILE                            = 0x102E,
  CL_DEVICE_VERSION                            = 0x102F,
  CL_DEVICE_EXTENSIONS                         = 0x1030,
  CL_DEVICE_PLATFORM                           = 0x1031,
  CL_DEVICE_DOUBLE_FP_CONFIG                   = 0x1032,
  CL_DEVICE_HALF_FP_CONFIG                     = 0x1033,
  CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF        = 0x1034,
  CL_DEVICE_HOST_UNIFIED_MEMORY                = 0x1035,
  CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR           = 0x1036,
  CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT          = 0x1037,
  CL_DEVICE_NATIVE_VECTOR_WIDTH_INT            = 0x1038,
  CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG           = 0x1039,
  CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT          = 0x103A,
  CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE         = 0x103B,
  CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF           = 0x103C,
  CL_DEVICE_OPENCL_C_VERSION                   = 0x103D,
  CL_FP_DENORM                                 = 0x01,
  CL_FP_INF_NAN                                = 0x02,
  CL_FP_ROUND_TO_NEAREST                       = 0x04,
  CL_FP_ROUND_TO_ZERO                          = 0x08,
  CL_FP_ROUND_TO_INF                           = 0x10,
  CL_FP_FMA                                    = 0x20,
  CL_FP_SOFT_FLOAT                             = 0x40, 
  CL_NONE                                      = 0x0,
  CL_READ_ONLY_CACHE                           = 0x1,
  CL_READ_WRITE_CACHE                          = 0x2,
  CL_LOCAL                                     = 0x1,
  CL_GLOBAL                                    = 0x2,
  CL_EXEC_KERNEL                               = 0x1,
  CL_EXEC_NATIVE_KERNEL                        = 0x2,
  CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE       = 0x1,
  CL_QUEUE_PROFILING_ENABLE                    = 0x2,
  CL_CONTEXT_REFERENCE_COUNT                   = 0x1080,
  CL_CONTEXT_DEVICES                           = 0x1081,
  CL_CONTEXT_PROPERTIES                        = 0x1082,
  CL_CONTEXT_NUM_DEVICES                       = 0x1083,
  CL_CONTEXT_PLATFORM                          = 0x1084,
  CL_QUEUE_CONTEXT                             = 0x1090,
  CL_QUEUE_DEVICE                              = 0x1091,
  CL_QUEUE_REFERENCE_COUNT                     = 0x1092,
  CL_QUEUE_PROPERTIES                          = 0x1093,
  CL_MEM_READ_WRITE                            = 0x01,
  CL_MEM_WRITE_ONLY                            = 0x02,
  CL_MEM_READ_ONLY                             = 0x04,
  CL_MEM_USE_HOST_PTR                          = 0x08,
  CL_MEM_ALLOC_HOST_PTR                        = 0x10,
  CL_MEM_COPY_HOST_PTR                         = 0x20,
  CL_R                                         = 0x10B0,
  CL_A                                         = 0x10B1,
  CL_RG                                        = 0x10B2,
  CL_RA                                        = 0x10B3,
  CL_RGB                                       = 0x10B4,
  CL_RGBA                                      = 0x10B5,
  CL_BGRA                                      = 0x10B6,
  CL_ARGB                                      = 0x10B7,
  CL_INTENSITY                                 = 0x10B8,
  CL_LUMINANCE                                 = 0x10B9,
  CL_Rx                                        = 0x10BA,
  CL_RGx                                       = 0x10BB,
  CL_RGBx                                      = 0x10BC,
  CL_SNORM_INT8                                = 0x10D0,
  CL_SNORM_INT16                               = 0x10D1,
  CL_UNORM_INT8                                = 0x10D2,
  CL_UNORM_INT16                               = 0x10D3,
  CL_UNORM_SHORT_565                           = 0x10D4,
  CL_UNORM_SHORT_555                           = 0x10D5,
  CL_UNORM_INT_101010                          = 0x10D6,
  CL_SIGNED_INT8                               = 0x10D7,
  CL_SIGNED_INT16                              = 0x10D8,
  CL_SIGNED_INT32                              = 0x10D9,
  CL_UNSIGNED_INT8                             = 0x10DA,
  CL_UNSIGNED_INT16                            = 0x10DB,
  CL_UNSIGNED_INT32                            = 0x10DC,
  CL_HALF_FLOAT                                = 0x10DD,
  CL_FLOAT                                     = 0x10DE,
  CL_MEM_OBJECT_BUFFER                         = 0x10F0,
  CL_MEM_OBJECT_IMAGE2D                        = 0x10F1,
  CL_MEM_OBJECT_IMAGE3D                        = 0x10F2,
  CL_MEM_TYPE                                  = 0x1100,
  CL_MEM_FLAGS                                 = 0x1101,
  CL_MEM_SIZE                                  = 0x1102,
  CL_MEM_HOST_PTR                              = 0x1103,
  CL_MEM_MAP_COUNT                             = 0x1104,
  CL_MEM_REFERENCE_COUNT                       = 0x1105,
  CL_MEM_CONTEXT                               = 0x1106,
  CL_MEM_ASSOCIATED_MEMOBJECT                  = 0x1107,
  CL_MEM_OFFSET                                = 0x1108,
  CL_IMAGE_FORMAT                              = 0x1110,
  CL_IMAGE_ELEMENT_SIZE                        = 0x1111,
  CL_IMAGE_ROW_PITCH                           = 0x1112,
  CL_IMAGE_SLICE_PITCH                         = 0x1113,
  CL_IMAGE_WIDTH                               = 0x1114,
  CL_IMAGE_HEIGHT                              = 0x1115,
  CL_IMAGE_DEPTH                               = 0x1116,
  CL_ADDRESS_NONE                              = 0x1130,
  CL_ADDRESS_CLAMP_TO_EDGE                     = 0x1131,
  CL_ADDRESS_CLAMP                             = 0x1132,
  CL_ADDRESS_REPEAT                            = 0x1133,
  CL_ADDRESS_MIRRORED_REPEAT                   = 0x1134,
  CL_FILTER_NEAREST                            = 0x1140,
  CL_FILTER_LINEAR                             = 0x1141,
  CL_SAMPLER_REFERENCE_COUNT                   = 0x1150,
  CL_SAMPLER_CONTEXT                           = 0x1151,
  CL_SAMPLER_NORMALIZED_COORDS                 = 0x1152,
  CL_SAMPLER_ADDRESSING_MODE                   = 0x1153,
  CL_SAMPLER_FILTER_MODE                       = 0x1154,
  CL_MAP_READ                                  = 0x01,
  CL_MAP_WRITE                                 = 0x02,
  CL_PROGRAM_REFERENCE_COUNT                   = 0x1160,
  CL_PROGRAM_CONTEXT                           = 0x1161,
  CL_PROGRAM_NUM_DEVICES                       = 0x1162,
  CL_PROGRAM_DEVICES                           = 0x1163,
  CL_PROGRAM_SOURCE                            = 0x1164,
  CL_PROGRAM_BINARY_SIZES                      = 0x1165,
  CL_PROGRAM_BINARIES                          = 0x1166,
  CL_PROGRAM_BUILD_STATUS                      = 0x1181,
  CL_PROGRAM_BUILD_OPTIONS                     = 0x1182,
  CL_PROGRAM_BUILD_LOG                         = 0x1183,
  CL_BUILD_SUCCESS                             = 0,
  CL_BUILD_NONE                                = -1,
  CL_BUILD_ERROR                               = -2,
  CL_BUILD_IN_PROGRESS                         = -3,
  CL_KERNEL_FUNCTION_NAME                      = 0x1190,
  CL_KERNEL_NUM_ARGS                           = 0x1191,
  CL_KERNEL_REFERENCE_COUNT                    = 0x1192,
  CL_KERNEL_CONTEXT                            = 0x1193,
  CL_KERNEL_PROGRAM                            = 0x1194,
  CL_KERNEL_WORK_GROUP_SIZE                    = 0x11B0,
  CL_KERNEL_COMPILE_WORK_GROUP_SIZE            = 0x11B1,
  CL_KERNEL_LOCAL_MEM_SIZE                     = 0x11B2,
  CL_KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE = 0x11B3,
  CL_KERNEL_PRIVATE_MEM_SIZE                   = 0x11B4,
  CL_EVENT_COMMAND_QUEUE                       = 0x11D0,
  CL_EVENT_COMMAND_TYPE                        = 0x11D1,
  CL_EVENT_REFERENCE_COUNT                     = 0x11D2,
  CL_EVENT_COMMAND_EXECUTION_STATUS            = 0x11D3,
  CL_EVENT_CONTEXT                             = 0x11D4,
  CL_COMMAND_NDRANGE_KERNEL                    = 0x11F0,
  CL_COMMAND_TASK                              = 0x11F1,
  CL_COMMAND_NATIVE_KERNEL                     = 0x11F2,
  CL_COMMAND_READ_BUFFER                       = 0x11F3,
  CL_COMMAND_WRITE_BUFFER                      = 0x11F4,
  CL_COMMAND_COPY_BUFFER                       = 0x11F5,
  CL_COMMAND_READ_IMAGE                        = 0x11F6,
  CL_COMMAND_WRITE_IMAGE                       = 0x11F7,
  CL_COMMAND_COPY_IMAGE                        = 0x11F8,
  CL_COMMAND_COPY_IMAGE_TO_BUFFER              = 0x11F9,
  CL_COMMAND_COPY_BUFFER_TO_IMAGE              = 0x11FA,
  CL_COMMAND_MAP_BUFFER                        = 0x11FB,
  CL_COMMAND_MAP_IMAGE                         = 0x11FC,
  CL_COMMAND_UNMAP_MEM_OBJECT                  = 0x11FD,
  CL_COMMAND_MARKER                            = 0x11FE,
  CL_COMMAND_ACQUIRE_GL_OBJECTS                = 0x11FF,
  CL_COMMAND_RELEASE_GL_OBJECTS                = 0x1200,
  CL_COMMAND_READ_BUFFER_RECT                  = 0x1201,
  CL_COMMAND_WRITE_BUFFER_RECT                 = 0x1202,
  CL_COMMAND_COPY_BUFFER_RECT                  = 0x1203,
  CL_COMMAND_USER                              = 0x1204,
  CL_COMPLETE                                  = 0x0,
  CL_RUNNING                                   = 0x1,
  CL_SUBMITTED                                 = 0x2,
  CL_QUEUED                                    = 0x3,
  CL_BUFFER_CREATE_TYPE_REGION                 = 0x1220,
  CL_PROFILING_COMMAND_QUEUED                  = 0x1280,
  CL_PROFILING_COMMAND_SUBMIT                  = 0x1281,
  CL_PROFILING_COMMAND_START                   = 0x1282,
  CL_PROFILING_COMMAND_END                     = 0x1283
};

typedef signed char               int8_t;
typedef short                     int16_t;
typedef int                       int32_t;
typedef long long                 int64_t;
typedef unsigned char             uint8_t;
typedef unsigned short            uint16_t;
typedef unsigned int              uint32_t;
typedef unsigned long long        uint64_t;
typedef int8_t                    int_least8_t;
typedef int16_t                   int_least16_t;
typedef int32_t                   int_least32_t;
typedef int64_t                   int_least64_t;
typedef uint8_t                   uint_least8_t;
typedef uint16_t                  uint_least16_t;
typedef uint32_t                  uint_least32_t;
typedef uint64_t                  uint_least64_t;
typedef int8_t                    int_fast8_t;
typedef int16_t                   int_fast16_t;
typedef int32_t                   int_fast32_t;
typedef int64_t                   int_fast64_t;
typedef uint8_t                   uint_fast8_t;
typedef uint16_t                  uint_fast16_t;
typedef uint32_t                  uint_fast32_t;
typedef uint64_t                  uint_fast64_t;
typedef long                      intptr_t;
typedef unsigned long             uintptr_t;
typedef long int                  intmax_t;
typedef long unsigned int         uintmax_t;
typedef int8_t                    cl_char;
typedef uint8_t                   cl_uchar;
typedef long int                  ptrdiff_t;
typedef long unsigned int         size_t;
typedef int                       wchar_t;
typedef int16_t                   cl_short        __attribute__((aligned(2)));
typedef uint16_t                  cl_ushort       __attribute__((aligned(2)));
typedef int32_t                   cl_int          __attribute__((aligned(4)));
typedef uint32_t                  cl_uint         __attribute__((aligned(4)));
typedef int64_t                   cl_long         __attribute__((aligned(8)));
typedef uint64_t                  cl_ulong        __attribute__((aligned(8)));
typedef uint16_t                  cl_half         __attribute__((aligned(2)));
typedef float                     cl_float        __attribute__((aligned(4)));
typedef double                    cl_double       __attribute__((aligned(8)));
typedef int8_t                    cl_char2[2]     __attribute__((aligned(2)));
typedef int8_t                    cl_char4[4]     __attribute__((aligned(4)));
typedef int8_t                    cl_char8[8]     __attribute__((aligned(8)));
typedef int8_t                    cl_char16[16]   __attribute__((aligned(16)));
typedef uint8_t                   cl_uchar2[2]    __attribute__((aligned(2)));
typedef uint8_t                   cl_uchar4[4]    __attribute__((aligned(4)));
typedef uint8_t                   cl_uchar8[8]    __attribute__((aligned(8)));
typedef uint8_t                   cl_uchar16[16]  __attribute__((aligned(16)));
typedef int16_t                   cl_short2[2]    __attribute__((aligned(4)));
typedef int16_t                   cl_short4[4]    __attribute__((aligned(8)));
typedef int16_t                   cl_short8[8]    __attribute__((aligned(16)));
typedef int16_t                   cl_short16[16]  __attribute__((aligned(32)));
typedef uint16_t                  cl_ushort2[2]   __attribute__((aligned(4)));
typedef uint16_t                  cl_ushort4[4]   __attribute__((aligned(8)));
typedef uint16_t                  cl_ushort8[8]   __attribute__((aligned(16)));
typedef uint16_t                  cl_ushort16[16] __attribute__((aligned(32)));
typedef int32_t                   cl_int2[2]      __attribute__((aligned(8)));
typedef int32_t                   cl_int4[4]      __attribute__((aligned(16)));
typedef int32_t                   cl_int8[8]      __attribute__((aligned(32)));
typedef int32_t                   cl_int16[16]    __attribute__((aligned(64)));
typedef uint32_t                  cl_uint2[2]     __attribute__((aligned(8)));
typedef uint32_t                  cl_uint4[4]     __attribute__((aligned(16)));
typedef uint32_t                  cl_uint8[8]     __attribute__((aligned(32)));
typedef uint32_t                  cl_uint16[16]   __attribute__((aligned(64)));
typedef int64_t                   cl_long2[2]     __attribute__((aligned(16)));
typedef int64_t                   cl_long4[4]     __attribute__((aligned(32)));
typedef int64_t                   cl_long8[8]     __attribute__((aligned(64)));
typedef int64_t                   cl_long16[16]   __attribute__((aligned(128)));
typedef uint64_t                  cl_ulong2[2]    __attribute__((aligned(16)));
typedef uint64_t                  cl_ulong4[4]    __attribute__((aligned(32)));
typedef uint64_t                  cl_ulong8[8]    __attribute__((aligned(64)));
typedef uint64_t                  cl_ulong16[16]  __attribute__((aligned(128)));
typedef float                     cl_float2[2]    __attribute__((aligned(8)));
typedef float                     cl_float4[4]    __attribute__((aligned(16)));
typedef float                     cl_float8[8]    __attribute__((aligned(32)));
typedef float                     cl_float16[16]  __attribute__((aligned(64)));
typedef double                    cl_double2[2]   __attribute__((aligned(16)));
typedef double                    cl_double4[4]   __attribute__((aligned(32)));
typedef double                    cl_double8[8]   __attribute__((aligned(64)));
typedef double                    cl_double16[16] __attribute__((aligned(128)));
typedef struct _cl_platform_id*   cl_platform_id;
typedef struct _cl_device_id*     cl_device_id;
typedef struct _cl_context*       cl_context;
typedef struct _cl_command_queue* cl_command_queue;
typedef struct _cl_mem*           cl_mem;
typedef struct _cl_program*       cl_program;
typedef struct _cl_kernel*        cl_kernel;
typedef struct _cl_event*         cl_event;
typedef struct _cl_sampler*       cl_sampler;
typedef cl_uint                   cl_bool;
typedef cl_ulong                  cl_bitfield;
typedef cl_bitfield               cl_device_type;
typedef cl_uint                   cl_platform_info;
typedef cl_uint                   cl_device_info;
typedef cl_bitfield               cl_device_address_info;
typedef cl_bitfield               cl_device_fp_config;
typedef cl_uint                   cl_device_mem_cache_type;
typedef cl_uint                   cl_device_local_mem_type;
typedef cl_bitfield               cl_device_exec_capabilities;
typedef cl_bitfield               cl_command_queue_properties;
typedef intptr_t                  cl_context_properties;
typedef cl_uint                   cl_context_info;
typedef cl_uint                   cl_command_queue_info;
typedef cl_uint                   cl_channel_order;
typedef cl_uint                   cl_channel_type;
typedef cl_bitfield               cl_mem_flags;
typedef cl_uint                   cl_mem_object_type;
typedef cl_uint                   cl_mem_info;
typedef cl_uint                   cl_image_info;
typedef cl_uint                   cl_addressing_mode;
typedef cl_uint                   cl_filter_mode;
typedef cl_uint                   cl_sampler_info;
typedef cl_bitfield               cl_map_flags;
typedef cl_uint                   cl_program_info;
typedef cl_uint                   cl_program_build_info;
typedef cl_int                    cl_build_status;
typedef cl_uint                   cl_kernel_info;
typedef cl_uint                   cl_kernel_work_group_info;
typedef cl_uint                   cl_event_info;
typedef cl_uint                   cl_command_type;
typedef cl_uint                   cl_profiling_info;

typedef struct _cl_image_format {
  cl_channel_order image_channel_order;
  cl_channel_type  image_channel_data_type;
} cl_image_format;

cl_int           clGetPlatformIDs(              cl_uint, cl_platform_id *, cl_uint *);
cl_int           clGetPlatformInfo(             cl_platform_id, cl_platform_info, size_t, void *, size_t *);
cl_int           clGetDeviceIDs(                cl_platform_id, cl_device_type, cl_uint, cl_device_id *, cl_uint *);
cl_int           clGetDeviceInfo(               cl_device_id,   cl_device_info, size_t, void *, size_t *);
cl_context       clCreateContext(               const cl_context_properties *, cl_uint, const cl_device_id *, void (*pfn_notify)(const char *, const void *, size_t, void *), void *, cl_int *);
cl_context       clCreateContextFromType(       const cl_context_properties *, cl_device_type, void (*pfn_notify)(const char *, const void *, size_t, void *), void *, cl_int *);
cl_int           clRetainContext(               cl_context );
cl_int           clReleaseContext(              cl_context );
cl_int           clGetContextInfo(              cl_context, cl_context_info, size_t, void *, size_t *);
cl_command_queue clCreateCommandQueue(          cl_context, cl_device_id, cl_command_queue_properties, cl_int *);
cl_int           clRetainCommandQueue(          cl_command_queue );
cl_int           clReleaseCommandQueue(         cl_command_queue );
cl_int           clGetCommandQueueInfo(         cl_command_queue, cl_command_queue_info, size_t, void *, size_t * );
cl_int           clSetCommandQueueProperty(     cl_command_queue, cl_command_queue_properties, cl_bool, cl_command_queue_properties * );
cl_mem           clCreateBuffer(                cl_context, cl_mem_flags, size_t, void *, cl_int *);
cl_mem           clCreateImage2D(               cl_context, cl_mem_flags, const cl_image_format *, size_t, size_t, size_t, void *, cl_int * );
cl_mem           clCreateImage3D(               cl_context, cl_mem_flags, const cl_image_format *, size_t, size_t, size_t, size_t, size_t, void *, cl_int *);
cl_int           clRetainMemObject(             cl_mem );
cl_int           clReleaseMemObject(            cl_mem );
cl_int           clGetSupportedImageFormats(    cl_context, cl_mem_flags, cl_mem_object_type, cl_uint, cl_image_format *, cl_uint *);
cl_int           clGetMemObjectInfo(            cl_mem, cl_mem_info, size_t, void *, size_t * );
cl_int           clGetImageInfo(                cl_mem, cl_image_info, size_t, void *, size_t * );
cl_sampler       clCreateSampler(               cl_context, cl_bool, cl_addressing_mode, cl_filter_mode, cl_int * );
cl_int           clRetainSampler(               cl_sampler );
cl_int           clReleaseSampler(              cl_sampler );
cl_int           clGetSamplerInfo(              cl_sampler, cl_sampler_info, size_t, void *, size_t * );
cl_program       clCreateProgramWithSource(     cl_context, cl_uint, const char **, const size_t *, cl_int * );
cl_program       clCreateProgramWithBinary(     cl_context, cl_uint, const cl_device_id *, const size_t *, const unsigned char **, cl_int *, cl_int * );
cl_int           clRetainProgram(               cl_program );
cl_int           clReleaseProgram(              cl_program );
cl_int           clBuildProgram(                cl_program, cl_uint, const cl_device_id *, const char *, void (*pfn_notify)(cl_program, void *), void * );
cl_int           clUnloadCompiler(              void );
cl_int           clGetProgramInfo(              cl_program, cl_program_info, size_t, void *, size_t * );
cl_int           clGetProgramBuildInfo(         cl_program, cl_device_id, cl_program_build_info, size_t, void *, size_t *);
cl_kernel        clCreateKernel(                cl_program, const char *, cl_int *);
cl_int           clCreateKernelsInProgram(      cl_program, cl_uint, cl_kernel *, cl_uint * );
cl_int           clRetainKernel(                cl_kernel );
cl_int           clReleaseKernel(               cl_kernel );
cl_int           clSetKernelArg(                cl_kernel, cl_uint, size_t, const void *);
cl_int           clGetKernelInfo(               cl_kernel, cl_kernel_info, size_t, void *, size_t * );
cl_int           clGetKernelWorkGroupInfo(      cl_kernel, cl_device_id, cl_kernel_work_group_info, size_t, void *, size_t * );
cl_int           clWaitForEvents(               cl_uint, const cl_event * );
cl_int           clGetEventInfo(                cl_event, cl_event_info, size_t, void *, size_t * );
cl_int           clRetainEvent(                 cl_event );
cl_int           clReleaseEvent(                cl_event );
cl_int           clGetEventProfilingInfo(       cl_event, cl_profiling_info, size_t, void *, size_t * );
cl_int           clFlush(                       cl_command_queue );
cl_int           clFinish(                      cl_command_queue );
cl_int           clEnqueueReadBuffer(           cl_command_queue, cl_mem, cl_bool, size_t, size_t, void *, cl_uint, const cl_event *, cl_event * );
cl_int           clEnqueueWriteBuffer(          cl_command_queue, cl_mem, cl_bool, size_t, size_t, const void *, cl_uint, const cl_event *, cl_event *);
cl_int           clEnqueueCopyBuffer(           cl_command_queue, cl_mem, cl_mem, size_t, size_t, size_t, cl_uint, const cl_event *, cl_event * );
cl_int           clEnqueueReadImage(            cl_command_queue, cl_mem, cl_bool, const size_t *, const size_t *, size_t, size_t, void *, cl_uint, const cl_event *, cl_event *);
cl_int           clEnqueueWriteImage(           cl_command_queue, cl_mem, cl_bool, const size_t *, const size_t *, size_t, size_t, const void *, cl_uint, const cl_event *, cl_event *);
cl_int           clEnqueueCopyImage(            cl_command_queue, cl_mem, cl_mem, const size_t *, const size_t *, const size_t *, cl_uint, const cl_event *, cl_event * );
cl_int           clEnqueueCopyImageToBuffer(    cl_command_queue, cl_mem, cl_mem, const size_t *, const size_t *, size_t, cl_uint, const cl_event *, cl_event *);
cl_int           clEnqueueCopyBufferToImage(    cl_command_queue, cl_mem, cl_mem, size_t, const size_t *, const size_t *, cl_uint, const cl_event *, cl_event *);
void*            clEnqueueMapBuffer(            cl_command_queue, cl_mem, cl_bool, cl_map_flags, size_t, size_t, cl_uint, const cl_event *, cl_event *, cl_int *);
void*            clEnqueueMapImage(             cl_command_queue, cl_mem, cl_bool, cl_map_flags, const size_t *, const size_t *, size_t *, size_t *, cl_uint, const cl_event *, cl_event *, cl_int *);
cl_int           clEnqueueUnmapMemObject(       cl_command_queue, cl_mem, void *, cl_uint, const cl_event *, cl_event *);
cl_int           clEnqueueNDRangeKernel(        cl_command_queue, cl_kernel, cl_uint, const size_t *, const size_t *, const size_t *, cl_uint, const cl_event *, cl_event *);
cl_int           clEnqueueTask(                 cl_command_queue, cl_kernel, cl_uint, const cl_event *, cl_event *);
cl_int           clEnqueueNativeKernel(         cl_command_queue, void (*user_func)(void *), void*, size_t, cl_uint, const cl_mem*, const void**, cl_uint, const cl_event*, cl_event*);
cl_int           clEnqueueMarker(               cl_command_queue, cl_event *);
cl_int           clEnqueueWaitForEvents(        cl_command_queue, cl_uint, const cl_event*);
cl_int           clEnqueueBarrier(              cl_command_queue);
void*            clGetExtensionFunctionAddress( const char* );
]]

ffi.cdef[[
enum {
  cl_APPLE_SetMemObjectDestructor             = 1,
  cl_APPLE_ContextLoggingFunctions            = 1,
  cl_khr_icd                                  = 1,
  cl_amd_device_memory_flags                  = 1,
  cl_amd_atomic_counters                      = 1,
  cl_ext_device_fission                       = 1,
};
enum {
  CL_PLATFORM_ICD_SUFFIX_KHR                  = 0x0920,
  CL_PLATFORM_NOT_FOUND_KHR                   = -1001,
  CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV       = 0x4000,
  CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV       = 0x4001,
  CL_DEVICE_REGISTERS_PER_BLOCK_NV            = 0x4002,
  CL_DEVICE_WARP_SIZE_NV                      = 0x4003,
  CL_DEVICE_GPU_OVERLAP_NV                    = 0x4004,
  CL_DEVICE_KERNEL_EXEC_TIMEOUT_NV            = 0x4005,
  CL_DEVICE_INTEGRATED_MEMORY_NV              = 0x4006,
  CL_MEM_USE_PERSISTENT_MEM_AMD               = 1 << 6,
  CL_DEVICE_PROFILING_TIMER_OFFSET_AMD        = 0x4036,
  CL_CONTEXT_OFFLINE_DEVICES_AMD              = 0x403F,
  CL_INVALID_COUNTER_AMD                      = -10000,
  CL_DEVICE_MAX_ATOMIC_COUNTERS_AMD           = 0x10000,
  CL_COUNTER_INC_ONLY_AMD                     = 1 << 0,
  CL_COUNTER_DEC_ONLY_AMD                     = 1 << 1,
  CL_COUNTER_FLAGS_AMD                        = 0x10001,
  CL_COUNTER_REFERENCE_COUNT_AMD              = 0x10002,
  CL_COUNTER_CONTEXT_AMD                      = 0x10003,
  CL_COMMAND_READ_COUNTER_AMD                 = 0x10004,
  CL_COMMAND_WRITE_COUNTER_AMD                = 0x10005,
  CL_DEVICE_PARTITION_EQUALLY_EXT             = 0x4050,
  CL_DEVICE_PARTITION_BY_COUNTS_EXT           = 0x4051,
  CL_DEVICE_PARTITION_BY_NAMES_EXT            = 0x4052,
  CL_DEVICE_PARTITION_BY_AFFINITY_DOMAIN_EXT  = 0x4053,
  CL_DEVICE_PARENT_DEVICE_EXT                 = 0x4054,
  CL_DEVICE_PARTITION_TYPES_EXT               = 0x4055,
  CL_DEVICE_AFFINITY_DOMAINS_EXT              = 0x4056,
  CL_DEVICE_REFERENCE_COUNT_EXT               = 0x4057,
  CL_DEVICE_PARTITION_STYLE_EXT               = 0x4058,
  CL_DEVICE_PARTITION_FAILED_EXT              = -1057,
  CL_INVALID_PARTITION_COUNT_EXT              = -1058,
  CL_INVALID_PARTITION_NAME_EXT               = -1059,
  CL_AFFINITY_DOMAIN_L1_CACHE_EXT             = 0x1,
  CL_AFFINITY_DOMAIN_L2_CACHE_EXT             = 0x2,
  CL_AFFINITY_DOMAIN_L3_CACHE_EXT             = 0x3,
  CL_AFFINITY_DOMAIN_L4_CACHE_EXT             = 0x4,
  CL_AFFINITY_DOMAIN_NUMA_EXT                 = 0x10,
  CL_AFFINITY_DOMAIN_NEXT_FISSIONABLE_EXT     = 0x100,
  CL_PROPERTIES_LIST_END_EXT                  = 0UL,
  CL_PARTITION_BY_COUNTS_LIST_END_EXT         = 0UL,
  CL_PARTITION_BY_NAMES_LIST_END_EXT          = -1UL,
};

typedef struct _cl_counter_amd* cl_counter_amd;
typedef cl_bitfield             cl_counter_flags_amd;
typedef cl_uint                 cl_counter_info_amd;
typedef cl_ulong                cl_device_partition_property_ext;

typedef cl_int         (* clIcdGetPlatformIDsKHR_fn)(   cl_uint, cl_platform_id *, cl_uint *);
typedef cl_counter_amd (* clCreateCounterAMD_fn)(       cl_context,     cl_counter_flags_amd, cl_uint, cl_int * );
typedef cl_int         (* clGetCounterInfoAMD_fn)(      cl_counter_amd, cl_counter_info_amd, size_t, void *, size_t * );
typedef cl_int         (* clRetainCounterAMD_fn)(       cl_counter_amd  );
typedef cl_int         (* clReleaseCounterAMD_fn)(      cl_counter_amd  );
typedef cl_int         (* clEnqueueReadCounterAMD_fn)(  cl_command_queue, cl_counter_amd, cl_bool, cl_uint *, cl_uint, const cl_event *, cl_event * );
typedef cl_int         (* clEnqueueWriteCounterAMD_fn)( cl_command_queue, cl_counter_amd, cl_bool, cl_uint, cl_uint, const cl_event *, cl_event * );
typedef cl_int         (* clReleaseDeviceEXT_fn)(       cl_device_id );
typedef cl_int         (* clRetainDeviceEXT_fn)(        cl_device_id );
typedef cl_int         (* clCreateSubDevicesEXT_fn)(    cl_device_id, const cl_device_partition_property_ext*, cl_uint, cl_device_id*, cl_uint *);

cl_int clSetMemObjectDestructorAPPLE( cl_mem, void (* )( cl_mem, void* ), void* );
void   clLogMessagesToSystemLogAPPLE( const char *, const void *, size_t, void* );
void   clLogMessagesToStdoutAPPLE(    const char *, const void *, size_t, void* );
void   clLogMessagesToStderrAPPLE(    const char *, const void *, size_t, void* );
cl_int clIcdGetPlatformIDsKHR(        cl_uint, cl_platform_id *, cl_uint * );
cl_int clReleaseDeviceEXT(            cl_device_id );
cl_int clRetainDeviceEXT(             cl_device_id );
cl_int clCreateSubDevicesEXT(         cl_device_id, const cl_device_partition_property_ext*, cl_uint, cl_device_id *, cl_uint *);
]]

ffi.cdef[[
typedef unsigned int     cl_GLuint;
typedef int              cl_GLint;
typedef unsigned int     cl_GLenum;
typedef cl_uint          cl_gl_object_type;
typedef cl_uint          cl_gl_texture_info;
typedef cl_uint          cl_gl_platform_info;
typedef cl_uint          cl_gl_context_info;
typedef struct __GLsync* cl_GLsync;
typedef cl_int        (* clGetGLContextInfoKHR_fn)( const cl_context_properties *, cl_gl_context_info, size_t, void *, size_t * );
    
enum {
  cl_khr_gl_sharing                      = 1,
  CL_GL_OBJECT_BUFFER                    = 0x2000,
  CL_GL_OBJECT_TEXTURE2D                 = 0x2001,
  CL_GL_OBJECT_TEXTURE3D                 = 0x2002,
  CL_GL_OBJECT_RENDERBUFFER              = 0x2003,
  CL_GL_TEXTURE_TARGET                   = 0x2004,
  CL_GL_MIPMAP_LEVEL                     = 0x2005,  
  CL_INVALID_GL_SHAREGROUP_REFERENCE_KHR = -1000,
  CL_CURRENT_DEVICE_FOR_GL_CONTEXT_KHR   = 0x2006,
  CL_DEVICES_FOR_GL_CONTEXT_KHR          = 0x2007,
  CL_GL_CONTEXT_KHR                      = 0x2008,
  CL_EGL_DISPLAY_KHR                     = 0x2009,
  CL_GLX_DISPLAY_KHR                     = 0x200A,
  CL_WGL_HDC_KHR                         = 0x200B,
  CL_CGL_SHAREGROUP_KHR                  = 0x200C,
  CL_COMMAND_GL_FENCE_SYNC_OBJECT_KHR    = 0x200D,
};

cl_mem   clCreateFromGLBuffer(       cl_context, cl_mem_flags, cl_GLuint, int *);
cl_mem   clCreateFromGLTexture2D(    cl_context, cl_mem_flags, cl_GLenum, cl_GLint, cl_GLuint, cl_int *);
cl_mem   clCreateFromGLTexture3D(    cl_context, cl_mem_flags, cl_GLenum, cl_GLint, cl_GLuint, cl_int *);
cl_mem   clCreateFromGLRenderbuffer( cl_context, cl_mem_flags, cl_GLuint, cl_int *);
cl_int   clGetGLObjectInfo(          cl_mem, cl_gl_object_type*, cl_GLuint *);
cl_int   clGetGLTextureInfo(         cl_mem, cl_gl_texture_info, size_t, void *, size_t *);
cl_int   clEnqueueAcquireGLObjects(  cl_command_queue, cl_uint, const cl_mem *, cl_uint, const cl_event *, cl_event *);
cl_int   clEnqueueReleaseGLObjects(  cl_command_queue, cl_uint, const cl_mem *, cl_uint, const cl_event *, cl_event *);
cl_int   clGetGLContextInfoKHR(      const cl_context_properties*, cl_gl_context_info, size_t, void *, size_t *);
cl_event clCreateEventFromGLsyncKHR( cl_context, cl_GLsync, cl_int * );
]]

return cl
