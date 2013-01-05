-- #include "tiff.h"
-- #include "tiffvers.h"

local ffi = require( "ffi" )
ffi.cdef [[
  typedef enum TIFFDataType {
    TIFF_NOTYPE,
    TIFF_BYTE,
    TIFF_ASCII,
    TIFF_SHORT,
    TIFF_LONG,
    TIFF_RATIONAL,
    TIFF_SBYTE,
    TIFF_UNDEFINED,
    TIFF_SSHORT,
    TIFF_SLONG,
    TIFF_SRATIONAL,
    TIFF_FLOAT,
    TIFF_DOUBLE,
    TIFF_IFD,
    TIFF_LONG8,
    TIFF_SLONG8,
    TIFF_IFD8
  } TIFFDataType;

  enum {
    TIFF_ANY               = TIFF_NOTYPE,
    TIFF_VARIABLE          = -1,
    TIFF_SPP               = -2,
    TIFF_VARIABLE2         = -3,
    TIFF_FIELD_CUSTOM      = 65,
    TIFFPRINT_NONE         = 0x0,
    TIFFPRINT_STRIPS       = 0x1,
    TIFFPRINT_CURVES       = 0x2,
    TIFFPRINT_COLORMAP     = 0x4,
    TIFFPRINT_JPEGQTABLES  = 0x100,
    TIFFPRINT_JPEGACTABLES = 0x200,
    TIFFPRINT_JPEGDCTABLES = 0x200,
  };

  typedef struct tiff TIFF;
  typedef intptr_t ssize_t;
  typedef void* tiff_handle_t;
  
  typedef struct TIFFDisplay {
    float    d_mat[3][3];
    float    d_YCR;
    float    d_YCG;
    float    d_YCB;
    uint32_t d_Vrwr;
    uint32_t d_Vrwg;
    uint32_t d_Vrwb;
    float    d_Y0R;
    float    d_Y0G;
    float    d_Y0B;
    float    d_gammaR;
    float    d_gammaG;
    float    d_gammaB;
  } TIFFDisplay;

  typedef struct TIFFYCbCrToRGB {
   uint8_t*      clamptab;
   int*          Cr_r_tab;
   int*          Cb_b_tab;
   int32_t*      Cr_g_tab;
   int32_t*      Cb_g_tab;
   int32_t*      Y_tab;
  } TIFFYCbCrToRGB;

  typedef struct TIFFCIELabToRGB {
    int range;
    float rstep, gstep, bstep;
    float X0, Y0, Z0;
    TIFFDisplay display;
    float Yr2r[1500 + 1];
    float Yg2g[1500 + 1];
    float Yb2b[1500 + 1];
  } TIFFCIELabToRGB;

  typedef struct TIFFRGBAImage TIFFRGBAImage;
  typedef struct TIFFField TIFFField;
  typedef struct TIFFFieldArray TIFFFieldArray;

  typedef void (*TIFFTileContigRoutine)(   TIFFRGBAImage*, uint32_t*, uint32_t, uint32_t, uint32_t, uint32_t, int32_t, int32_t, unsigned char* );
  typedef void (*TIFFTileSeparateRoutine)( TIFFRGBAImage*, uint32_t*, uint32_t, uint32_t, uint32_t, uint32_t, int32_t, int32_t, unsigned char*, unsigned char*, unsigned char*, unsigned char* );
  
  struct TIFFRGBAImage {
    TIFF*            tif;
    int              stoponerr;
    int              isContig;
    int              alpha;
    uint32_t         width;
    uint32_t         height;
    uint16_t         bitspersample;
    uint16_t         samplesperpixel;
    uint16_t         orientation;
    uint16_t         req_orientation;
    uint16_t         photometric;
    uint16_t*        redcmap;
    uint16_t*        greencmap;
    uint16_t*        bluecmap;
    int    (* get )( TIFFRGBAImage*, uint32_t*, uint32_t, uint32_t );
    union {
      void (* any )( TIFFRGBAImage* );
      TIFFTileContigRoutine   contig;
      TIFFTileSeparateRoutine separate;
    } put;
    uint8_t*         Map;
    uint32_t**       BWmap;
    uint32_t**       PALmap;
    TIFFYCbCrToRGB*  ycbcr;
    TIFFCIELabToRGB* cielab;
    uint8_t*         UaToAa;
    uint8_t*         Bitdepth16To8;
    int              row_offset;
    int              col_offset;
  };

  typedef int (*TIFFInitMethod)(TIFF*, int);
  typedef struct TIFFCodec {
    char*          name;
    uint16_t       scheme;
    TIFFInitMethod init;
  } TIFFCodec;

  typedef void     (* TIFFErrorHandler )(    const char*, const char*, va_list);
  typedef void     (* TIFFErrorHandlerExt )( tiff_handle_t, const char*, const char*, va_list);
  typedef ssize_t  (* TIFFReadWriteProc )(   tiff_handle_t, void*, ssize_t);
  typedef uint64_t (* TIFFSeekProc )(        tiff_handle_t, uint64_t, int);
  typedef int      (* TIFFCloseProc )(       tiff_handle_t);
  typedef uint64_t (* TIFFSizeProc )(        tiff_handle_t);
  typedef int      (* TIFFMapFileProc )(     tiff_handle_t, void** base, uint64_t* size);
  typedef void     (* TIFFUnmapFileProc )(   tiff_handle_t, void* base, uint64_t size);
  typedef void     (* TIFFExtendProc )(      TIFF*  );
  typedef int      (* TIFFVSetMethod )(      TIFF*, uint32_t, va_list );
  typedef int      (* TIFFVGetMethod )(      TIFF*, uint32_t, va_list );
  typedef void     (* TIFFPrintMethod )(     TIFF*, void* /* FILE* */, long );

  typedef struct TIFFTagMethods {
    TIFFVSetMethod vsetfield; /* tag set routine */
    TIFFVGetMethod vgetfield; /* tag get routine */
    TIFFPrintMethod printdir; /* directory print routine */
  } TIFFTagMethods;

  const char*          TIFFGetVersion(            );
  const TIFFCodec*     TIFFFindCODEC(             uint16_t );
  TIFFCodec*           TIFFRegisterCODEC(         uint16_t, const char*, TIFFInitMethod);
  void                 TIFFUnRegisterCODEC(       TIFFCodec* );
  int                  TIFFIsCODECConfigured(     uint16_t );
  TIFFCodec*           TIFFGetConfiguredCODECs(   );
  void*               _TIFFmalloc(                ssize_t s );
  void*               _TIFFrealloc(               void* p, ssize_t s );
  void                _TIFFmemset(                void* p, int v, ssize_t c );
  void                _TIFFmemcpy(                void* d, const void*  s, ssize_t c );
  int                 _TIFFmemcmp(          const void* p, const void* p2, ssize_t c );
  void                _TIFFfree(                  void* p );
  int                  TIFFGetTagListCount(       TIFF*  );
  uint32_t             TIFFGetTagListEntry(       TIFF*, int tag_index );
  const TIFFField*     TIFFFindField(             TIFF *, uint32_t, TIFFDataType);
  const TIFFField*     TIFFFieldWithTag(          TIFF*, uint32_t);
  const TIFFField*     TIFFFieldWithName(         TIFF*, const char *);
  uint32_t             TIFFFieldTag(        const TIFFField* );
  const char*          TIFFFieldName(       const TIFFField* );
  TIFFDataType         TIFFFieldDataType(   const TIFFField* );
  int                  TIFFFieldPassCount(  const TIFFField* );
  int                  TIFFFieldReadCount(  const TIFFField* );
  int                  TIFFFieldWriteCount( const TIFFField* );
  TIFFTagMethods*      TIFFAccessTagMethods(      TIFF*  );
  void*                TIFFGetClientInfo(         TIFF*, const char *);
  void                 TIFFSetClientInfo(         TIFF*, void *, const char *);
  void                 TIFFCleanup(               TIFF*  );
  void                 TIFFClose(                 TIFF*  );
  int                  TIFFFlush(                 TIFF*  );
  int                  TIFFFlushData(             TIFF*  );
  int                  TIFFGetField(              TIFF*, uint32_t tag, ... );
  int                  TIFFVGetField(             TIFF*, uint32_t tag, va_list );
  int                  TIFFGetFieldDefaulted(     TIFF*, uint32_t tag, ...);
  int                  TIFFVGetFieldDefaulted(    TIFF*, uint32_t tag, va_list );
  int                  TIFFReadDirectory(         TIFF*  );
  int                  TIFFReadCustomDirectory(   TIFF*, uint64_t diroff, const TIFFFieldArray* infoarray );
  int                  TIFFReadEXIFDirectory(     TIFF*, uint64_t diroff  );
  uint64_t             TIFFScanlineSize64(        TIFF*  );
  ssize_t              TIFFScanlineSize(          TIFF*  );
  uint64_t             TIFFRasterScanlineSize64(  TIFF*  );
  ssize_t              TIFFRasterScanlineSize(    TIFF*  );
  uint64_t             TIFFStripSize64(           TIFF*  );
  ssize_t              TIFFStripSize(             TIFF*  );
  uint64_t             TIFFRawStripSize64(        TIFF*, uint32_t strip);
  ssize_t              TIFFRawStripSize(          TIFF*, uint32_t strip);
  uint64_t             TIFFVStripSize64(          TIFF*, uint32_t nrows);
  ssize_t              TIFFVStripSize(            TIFF*, uint32_t nrows);
  uint64_t             TIFFTileRowSize64(         TIFF*  );
  ssize_t              TIFFTileRowSize(           TIFF*  );
  uint64_t             TIFFTileSize64(            TIFF*  );
  ssize_t              TIFFTileSize(              TIFF*  );
  uint64_t             TIFFVTileSize64(           TIFF*, uint32_t nrows );
  ssize_t              TIFFVTileSize(             TIFF*, uint32_t nrows );
  uint32_t             TIFFDefaultStripSize(      TIFF*, uint32_t request );
  void                 TIFFDefaultTileSize(       TIFF*, uint32_t*, uint32_t* );
  int                  TIFFFileno(                TIFF*  );
  int                  TIFFSetFileno(             TIFF*, int );
  tiff_handle_t        TIFFClientdata(            TIFF*  );
  tiff_handle_t        TIFFSetClientdata(         TIFF*, tiff_handle_t );
  int                  TIFFGetMode(               TIFF*  );
  int                  TIFFSetMode(               TIFF*, int );
  int                  TIFFIsTiled(               TIFF*  );
  int                  TIFFIsByteSwapped(         TIFF*  );
  int                  TIFFIsUpSampled(           TIFF*  );
  int                  TIFFIsMSB2LSB(             TIFF*  );
  int                  TIFFIsBigEndian(           TIFF*  );
  TIFFReadWriteProc    TIFFGetReadProc(           TIFF*  );
  TIFFReadWriteProc    TIFFGetWriteProc(          TIFF*  );
  TIFFSeekProc         TIFFGetSeekProc(           TIFF*  );                                                          
  TIFFCloseProc        TIFFGetCloseProc(          TIFF*  );
  TIFFSizeProc         TIFFGetSizeProc(           TIFF*  );
  TIFFMapFileProc      TIFFGetMapFileProc(        TIFF*  );
  TIFFUnmapFileProc    TIFFGetUnmapFileProc(      TIFF*  );
  uint32_t             TIFFCurrentRow(            TIFF*  );
  uint16_t             TIFFCurrentDirectory(      TIFF*  );
  uint16_t             TIFFNumberOfDirectories(   TIFF*  );
  uint64_t             TIFFCurrentDirOffset(      TIFF*  );
  uint32_t             TIFFCurrentStrip(          TIFF*  );
  uint32_t             TIFFCurrentTile(           TIFF*  );
  int                  TIFFReadBufferSetup(       TIFF*, void* bp, ssize_t size);
  int                  TIFFWriteBufferSetup(      TIFF*, void* bp, ssize_t size);  
  int                  TIFFSetupStrips(           TIFF*  );
  int                  TIFFWriteCheck(            TIFF*, int, const char *);
  void                 TIFFFreeDirectory(         TIFF*  );
  int                  TIFFCreateDirectory(       TIFF*  );
  int                  TIFFCreateCustomDirectory( TIFF*, const TIFFFieldArray*);
  int                  TIFFCreateEXIFDirectory(   TIFF*  );
  int                  TIFFLastDirectory(         TIFF*  );
  int                  TIFFSetDirectory(          TIFF*, uint16_t );
  int                  TIFFSetSubDirectory(       TIFF*, uint64_t );
  int                  TIFFUnlinkDirectory(       TIFF*, uint16_t );
  int                  TIFFSetField(              TIFF*, uint32_t, ...);
  int                  TIFFVSetField(             TIFF*, uint32_t, va_list);
  int                  TIFFUnsetField(            TIFF*, uint32_t);
  int                  TIFFWriteDirectory(        TIFF* );
  int                  TIFFWriteCustomDirectory(  TIFF *, uint64_t *);
  int                  TIFFCheckpointDirectory(   TIFF *);
  int                  TIFFRewriteDirectory(      TIFF *);
  void                 TIFFPrintDirectory(        TIFF*, void* /* FILE* */, long);
  int                  TIFFReadScanline(          TIFF*, void* buf, uint32_t row, uint16_t sample);
  int                  TIFFWriteScanline(         TIFF*, void* buf, uint32_t row, uint16_t sample);
  int                  TIFFReadRGBAImage(         TIFF*, uint32_t, uint32_t, uint32_t*, int);
  int                  TIFFReadRGBAImageOriented( TIFF*, uint32_t, uint32_t, uint32_t*, int, int);
  int                  TIFFReadRGBAStrip(         TIFF*, uint32_t, uint32_t * );
  int                  TIFFReadRGBATile(          TIFF*, uint32_t, uint32_t, uint32_t * );
  int                  TIFFRGBAImageOK(           TIFF*, char [1024]);
  int                  TIFFRGBAImageBegin(        TIFFRGBAImage*, TIFF*, int, char [1024]);
  int                  TIFFRGBAImageGet(          TIFFRGBAImage*, uint32_t*, uint32_t, uint32_t);
  void                 TIFFRGBAImageEnd(          TIFFRGBAImage*  );
  TIFF*                TIFFOpen(            const char*, const char* );
  TIFF*                TIFFFdOpen(                int, const char*, const char* );
  TIFF*                TIFFClientOpen(      const char*, const char*, tiff_handle_t, TIFFReadWriteProc, TIFFReadWriteProc, TIFFSeekProc, TIFFCloseProc, TIFFSizeProc, TIFFMapFileProc, TIFFUnmapFileProc );
  const char*          TIFFFileName(              TIFF*  );
  const char*          TIFFSetFileName(           TIFF*, const char *);
  void                 TIFFError(           const char*, const char*, ...) __attribute__((__format__ (__printf__,2,3)));
  void                 TIFFErrorExt(              tiff_handle_t, const char*, const char*, ...) __attribute__((__format__ (__printf__,3,4)));
  void                 TIFFWarning(         const char*, const char*, ...) __attribute__((__format__ (__printf__,2,3)));
  void                 TIFFWarningExt(            tiff_handle_t, const char*, const char*, ...) __attribute__((__format__ (__printf__,3,4)));
  TIFFErrorHandler     TIFFSetErrorHandler(       TIFFErrorHandler );
  TIFFErrorHandlerExt  TIFFSetErrorHandlerExt(    TIFFErrorHandlerExt );
  TIFFErrorHandler     TIFFSetWarningHandler(     TIFFErrorHandler );
  TIFFErrorHandlerExt  TIFFSetWarningHandlerExt(  TIFFErrorHandlerExt );
  TIFFExtendProc       TIFFSetTagExtender(        TIFFExtendProc );
  uint32_t             TIFFComputeTile(           TIFF*, uint32_t x, uint32_t y, uint32_t z, uint16_t s );
  int                  TIFFCheckTile(             TIFF*, uint32_t x, uint32_t y, uint32_t z, uint16_t s);
  uint32_t             TIFFNumberOfTiles(         TIFF*);
  ssize_t              TIFFReadTile(              TIFF*, void* buf, uint32_t x, uint32_t y, uint32_t z, uint16_t s);  
  ssize_t              TIFFWriteTile(             TIFF*, void* buf, uint32_t x, uint32_t y, uint32_t z, uint16_t s);
  uint32_t             TIFFComputeStrip(          TIFF*, uint32_t, uint16_t);
  uint32_t             TIFFNumberOfStrips(        TIFF*);
  ssize_t              TIFFReadEncodedStrip(      TIFF*, uint32_t strip, void* buf, ssize_t size);
  ssize_t              TIFFReadRawStrip(          TIFF*, uint32_t strip, void* buf, ssize_t size);  
  ssize_t              TIFFReadEncodedTile(       TIFF*, uint32_t tile, void* buf, ssize_t size);  
  ssize_t              TIFFReadRawTile(           TIFF*, uint32_t tile, void* buf, ssize_t size);  
  ssize_t              TIFFWriteEncodedStrip(     TIFF*, uint32_t strip, void* data, ssize_t cc);
  ssize_t              TIFFWriteRawStrip(         TIFF*, uint32_t strip, void* data, ssize_t cc);  
  ssize_t              TIFFWriteEncodedTile(      TIFF*, uint32_t tile, void* data, ssize_t cc);  
  ssize_t              TIFFWriteRawTile(          TIFF*, uint32_t tile, void* data, ssize_t cc);  
  int                  TIFFDataWidth(             TIFFDataType );    /* table of tag datatype widths */
  void                 TIFFSetWriteOffset(        TIFF*, uint64_t off );
  void                 TIFFSwabShort(             uint16_t* );
  void                 TIFFSwabLong(              uint32_t* );
  void                 TIFFSwabLong8(             uint64_t* );
  void                 TIFFSwabFloat(             float* );
  void                 TIFFSwabDouble(            double* );
  void                 TIFFSwabArrayOfShort(      uint16_t* wp, ssize_t n );
  void                 TIFFSwabArrayOfTriples(    uint8_t* tp, ssize_t n);
  void                 TIFFSwabArrayOfLong(       uint32_t* lp, ssize_t n);
  void                 TIFFSwabArrayOfLong8(      uint64_t* lp, ssize_t n);
  void                 TIFFSwabArrayOfFloat(      float* fp, ssize_t n);
  void                 TIFFSwabArrayOfDouble(     double* dp, ssize_t n);
  void                 TIFFReverseBits(           uint8_t* cp, ssize_t n);
  const unsigned char* TIFFGetBitRevTable(        int );
  int                  TIFFCIELabToRGBInit(       TIFFCIELabToRGB*, const TIFFDisplay *, float*);
  void                 TIFFCIELabToXYZ(           TIFFCIELabToRGB *, uint32_t, int32_t, int32_t, float *, float *, float *);
  void                 TIFFXYZToRGB(              TIFFCIELabToRGB *, float, float, float, uint32_t *, uint32_t *, uint32_t *);
  int                  TIFFYCbCrToRGBInit(        TIFFYCbCrToRGB*, float*, float*);
  void                 TIFFYCbCrtoRGB(            TIFFYCbCrToRGB *, uint32_t, int32_t, int32_t, uint32_t *, uint32_t *, uint32_t *);
]]

return ffi.load( "tiff" ) 

