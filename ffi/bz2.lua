local ffi = require( "ffi" )

local libs = ffi_bz2_libs or {
   Windows = { x86 = "bin/Windows/x86/bz2.dll", x64 = "bin/Windows/x64/bz2.dll" },
}

local bz2 = ffi.load( ffi_zlib_lib or libs[ ffi.os ][ ffi.arch ] or "bz2" )

ffi.cdef[[
      enum {
	 BZ_MAX_UNUSED        = 5000,
	 BZ_RUN               =  0,
	 BZ_FLUSH             =  1,
	 BZ_FINISH            =  2,
	 BZ_OK                =  0,
	 BZ_RUN_OK            =  1,
	 BZ_FLUSH_OK          =  2,
	 BZ_FINISH_OK         =  3,
	 BZ_STREAM_END        =  4,
	 BZ_SEQUENCE_ERROR    = -1,
	 BZ_PARAM_ERROR       = -2,
	 BZ_MEM_ERROR         = -3,
	 BZ_DATA_ERROR        = -4,
	 BZ_DATA_ERROR_MAGIC  = -5,
	 BZ_IO_ERROR          = -6,
	 BZ_UNEXPECTED_EOF    = -7,
	 BZ_OUTBUFF_FULL      = -8,
	 BZ_CONFIG_ERROR      = -9,
      };

      typedef struct  bz_stream {
	 char*        next_in;
	 unsigned int avail_in;
	 unsigned int total_in_lo32;
	 unsigned int total_in_hi32;
	 char*        next_out;
	 unsigned int avail_out;
	 unsigned int total_out_lo32;
	 unsigned int total_out_hi32;
	 void*        state;
	 void*     (* bzalloc )( void *, int, int );
	 void      (* bzfree  )( void *, void* );
	 void*        opaque;
      } bz_stream;

      typedef void BZFILE;

      const char* BZ2_bzlibVersion(           );
      int         BZ2_bzCompressInit(         bz_stream*, int blockSize100k, int verbosity, int workFactor );
      int         BZ2_bzCompress(             bz_stream*, int action );
      int         BZ2_bzCompressEnd(          bz_stream* );
      int         BZ2_bzDecompressInit(       bz_stream*, int verbosity, int small );
      int         BZ2_bzDecompress(           bz_stream* );
      int         BZ2_bzDecompressEnd(        bz_stream* );
      BZFILE*     BZ2_bzReadOpen(             int* err, FILE* f, int verbosity, int small, void* unused, int nUnused );
      void        BZ2_bzReadClose(            int* err, BZFILE* b );
      void        BZ2_bzReadGetUnused(        int* err, BZFILE* b, void** unused, int* nUnused );
      int         BZ2_bzRead(                 int* err, BZFILE* b, void*  buf, int len );
      BZFILE*     BZ2_bzWriteOpen(            int* err, FILE* f, int blockSize100k, int verbosity, int workFactor );
      void        BZ2_bzWrite(                int* err, BZFILE* b, void* buf, int len );
      void        BZ2_bzWriteClose(           int* err, BZFILE* b, int abandon, unsigned int* nbytes_in, unsigned int* nbytes_out );
      void        BZ2_bzWriteClose64(         int* err, BZFILE* b, int abandon, unsigned int* nbytes_in_lo32, unsigned int* nbytes_in_hi32, unsigned int* nbytes_out_lo32, unsigned int* nbytes_out_hi32 );
      int         BZ2_bzBuffToBuffCompress(   char* dest, unsigned int* destLen, char* source, unsigned int sourceLen, int blockSize100k, int verbosity, int workFactor );
      int         BZ2_bzBuffToBuffDecompress( char* dest, unsigned int* destLen, char* source, unsigned int sourceLen, int small, int verbosity );
      BZFILE*     BZ2_bzopen(                 const char *path, const char *mode );
      BZFILE*     BZ2_bzdopen(                int fd, const char *mode );
      int         BZ2_bzread(                 BZFILE* b, void* buf, int len );
      int         BZ2_bzwrite(                BZFILE* b, void* buf, int len );
      int         BZ2_bzflush(                BZFILE* b );
      void        BZ2_bzclose(                BZFILE* b );
      const char* BZ2_bzerror(                BZFILE *b, int *errnum  );
]]

return bz2