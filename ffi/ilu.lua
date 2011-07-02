# 1 "/opt/local/include/IL/ilu.h"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/opt/local/include/IL/ilu.h"
# 105 "/opt/local/include/IL/ilu.h"
typedef struct ILinfo
{
 ILuint Id;
 ILubyte *Data;
 ILuint Width;
 ILuint Height;
 ILuint Depth;
 ILubyte Bpp;
 ILuint SizeOfData;
 ILenum Format;
 ILenum Type;
 ILenum Origin;
 ILubyte *Palette;
 ILenum PalType;
 ILuint PalSize;
 ILenum CubeFlags;
 ILuint NumNext;
 ILuint NumMips;
 ILuint NumLayers;
} ILinfo;


typedef struct ILpointf {
 ILfloat x;
 ILfloat y;
} ILpointf;

typedef struct ILpointi {
 ILint x;
 ILint y;
} ILpointi;

ILAPI ILboolean ILAPIENTRY iluAlienify(void);
ILAPI ILboolean ILAPIENTRY iluBlurAvg(ILuint Iter);
ILAPI ILboolean ILAPIENTRY iluBlurGaussian(ILuint Iter);
ILAPI ILboolean ILAPIENTRY iluBuildMipmaps(void);
ILAPI ILuint ILAPIENTRY iluColoursUsed(void);
ILAPI ILboolean ILAPIENTRY iluCompareImage(ILuint Comp);
ILAPI ILboolean ILAPIENTRY iluContrast(ILfloat Contrast);
ILAPI ILboolean ILAPIENTRY iluCrop(ILuint XOff, ILuint YOff, ILuint ZOff, ILuint Width, ILuint Height, ILuint Depth);
ILAPI void ILAPIENTRY iluDeleteImage(ILuint Id);
ILAPI ILboolean ILAPIENTRY iluEdgeDetectE(void);
ILAPI ILboolean ILAPIENTRY iluEdgeDetectP(void);
ILAPI ILboolean ILAPIENTRY iluEdgeDetectS(void);
ILAPI ILboolean ILAPIENTRY iluEmboss(void);
ILAPI ILboolean ILAPIENTRY iluEnlargeCanvas(ILuint Width, ILuint Height, ILuint Depth);
ILAPI ILboolean ILAPIENTRY iluEnlargeImage(ILfloat XDim, ILfloat YDim, ILfloat ZDim);
ILAPI ILboolean ILAPIENTRY iluEqualize(void);
ILAPI ILconst_string ILAPIENTRY iluErrorString(ILenum Error);
ILAPI ILboolean ILAPIENTRY iluConvolution(ILint *matrix, ILint scale, ILint bias);
ILAPI ILboolean ILAPIENTRY iluFlipImage(void);
ILAPI ILboolean ILAPIENTRY iluGammaCorrect(ILfloat Gamma);
ILAPI ILuint ILAPIENTRY iluGenImage(void);
ILAPI void ILAPIENTRY iluGetImageInfo(ILinfo *Info);
ILAPI ILint ILAPIENTRY iluGetInteger(ILenum Mode);
ILAPI void ILAPIENTRY iluGetIntegerv(ILenum Mode, ILint *Param);
ILAPI ILstring ILAPIENTRY iluGetString(ILenum StringName);
ILAPI void ILAPIENTRY iluImageParameter(ILenum PName, ILenum Param);
ILAPI void ILAPIENTRY iluInit(void);
ILAPI ILboolean ILAPIENTRY iluInvertAlpha(void);
ILAPI ILuint ILAPIENTRY iluLoadImage(ILconst_string FileName);
ILAPI ILboolean ILAPIENTRY iluMirror(void);
ILAPI ILboolean ILAPIENTRY iluNegative(void);
ILAPI ILboolean ILAPIENTRY iluNoisify(ILclampf Tolerance);
ILAPI ILboolean ILAPIENTRY iluPixelize(ILuint PixSize);
ILAPI void ILAPIENTRY iluRegionfv(ILpointf *Points, ILuint n);
ILAPI void ILAPIENTRY iluRegioniv(ILpointi *Points, ILuint n);
ILAPI ILboolean ILAPIENTRY iluReplaceColour(ILubyte Red, ILubyte Green, ILubyte Blue, ILfloat Tolerance);
ILAPI ILboolean ILAPIENTRY iluRotate(ILfloat Angle);
ILAPI ILboolean ILAPIENTRY iluRotate3D(ILfloat x, ILfloat y, ILfloat z, ILfloat Angle);
ILAPI ILboolean ILAPIENTRY iluSaturate1f(ILfloat Saturation);
ILAPI ILboolean ILAPIENTRY iluSaturate4f(ILfloat r, ILfloat g, ILfloat b, ILfloat Saturation);
ILAPI ILboolean ILAPIENTRY iluScale(ILuint Width, ILuint Height, ILuint Depth);
ILAPI ILboolean ILAPIENTRY iluScaleAlpha(ILfloat scale);
ILAPI ILboolean ILAPIENTRY iluScaleColours(ILfloat r, ILfloat g, ILfloat b);
ILAPI ILboolean ILAPIENTRY iluSetLanguage(ILenum Language);
ILAPI ILboolean ILAPIENTRY iluSharpen(ILfloat Factor, ILuint Iter);
ILAPI ILboolean ILAPIENTRY iluSwapColours(void);
ILAPI ILboolean ILAPIENTRY iluWave(ILfloat Angle);
