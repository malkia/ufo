ffi.cdef [[
      typedef unsigned char  FT_Bool;
      typedef signed short   FT_FWord;
      typedef unsigned short FT_UFWord;
      typedef signed char    FT_Char;
      typedef unsigned char  FT_Byte;
      typedef const FT_Byte* FT_Bytes;
      typedef uint32_t       FT_Tag;
      typedef char           FT_String;
      typedef signed short   FT_Short;
      typedef unsigned short FT_UShort;
      typedef signed int     FT_Int;
      typedef unsigned int   FT_UInt;
      typedef signed long    FT_Long;
      typedef unsigned long  FT_ULong;
      typedef signed short   FT_F2Dot14;
      typedef signed long    FT_F26Dot6;
      typedef signed long    FT_Fixed;
      typedef int            FT_Error;
      typedef void*          FT_Pointer;
      typedef size_t         FT_Offset;
      typedef ptrdiff_t      FT_PtrDist;
      typedef void        (* FT_Generic_Finalizer )( void* object );

      typedef struct {
	 FT_F2Dot14  x;
	 FT_F2Dot14  y;
      } FT_UnitVector;

      typedef struct {
	 FT_Fixed  xx, xy;
	 FT_Fixed  yx, yy;
      } FT_Matrix;

      typedef struct {
	 const FT_Byte* pointer;
	 FT_Int         length;
      } FT_Data;

      typedef struct {
	 void*                 data;
	 FT_Generic_Finalizer  finalizer;
      } FT_Generic;

      typedef struct  FT_Glyph_Metrics_
      {
	 FT_Pos  width;
	 FT_Pos  height;
	 FT_Pos  horiBearingX;
	 FT_Pos  horiBearingY;
	 FT_Pos  horiAdvance;
	 FT_Pos  vertBearingX;
	 FT_Pos  vertBearingY;
	 FT_Pos  vertAdvance;
      } FT_Glyph_Metrics;
]]