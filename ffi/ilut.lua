local ffi = require( "ffi" )

local libs = ffi_ilut_libs or {
   OSX = { x86 = "/opt/local/lib/libIULT.dylib", x64 = "/opt/local/lib/libIULT.dylib" },
}

local lib = ffi_ilut_lib or lib[ ffi.os ][ ffi.arch ]

local ilut = ffi.load( lib )

ffi.cdef[[
      ILboolean ilutDisable(ILenum Mode);
      ILboolean ilutEnable(ILenum Mode);
      ILboolean ilutGetBoolean(ILenum Mode);
      void      ilutGetBooleanv(ILenum Mode, ILboolean *Param);
      ILint     ilutGetInteger(ILenum Mode);
      void      ilutGetIntegerv(ILenum Mode, ILint *Param);
      ILstring  ilutGetString(ILenum StringName);
      void      ilutInit(void);
      ILboolean ilutIsDisabled(ILenum Mode);
      ILboolean ilutIsEnabled(ILenum Mode);
      void      ilutPopAttrib(void);
      void      ilutPushAttrib(ILuint Bits);
      void      ilutSetInteger(ILenum Mode, ILint Param);
      ILboolean ilutRenderer(ILenum Renderer);

      GLuint	 ilutGLBindTexImage();
      GLuint	 ilutGLBindMipmaps(void);
      ILboolean	 ilutGLBuildMipmaps(void);
      GLuint	 ilutGLLoadImage(ILstring FileName);
      ILboolean	 ilutGLScreen(void);
      ILboolean	 ilutGLScreenie(void);
      ILboolean	 ilutGLSaveImage(ILstring FileName, GLuint TexID);
      ILboolean  ilutGLSubTex2D(GLuint TexID, ILuint XOff, ILuint YOff);
      ILboolean  ilutGLSubTex3D(GLuint TexID, ILuint XOff, ILuint YOff, ILuint ZOff);
      ILboolean	 ilutGLSetTex2D(GLuint TexID);
      ILboolean	 ilutGLSetTex3D(GLuint TexID);
      ILboolean	 ilutGLTexImage(GLuint Level);
      ILboolean  ilutGLSubTex(GLuint TexID, ILuint XOff, ILuint YOff);
      ILboolean	 ilutGLSetTex(GLuint TexID);  // Deprecated - use ilutGLSetTex2D.
      ILboolean  ilutGLSubTex(GLuint TexID, ILuint XOff, ILuint YOff);  // Use ilutGLSubTex2D.

      BITMAP*    ilutAllegLoadImage(ILstring FileName);
      BITMAP*    ilutConvertToAlleg(PALETTE Pal);

      struct SDL_Surface* ilutConvertToSDLSurface(unsigned int flags);
      struct SDL_Surface* ilutSDLSurfaceLoadImage(ILstring FileName);
      ILboolean           ilutSDLSurfaceFromBitmap(struct SDL_Surface *Bitmap);

      BBitmap             ilutConvertToBBitmap(void);

      HBITMAP	 ilutConvertToHBitmap(HDC hDC);
      HBITMAP	 ilutConvertSliceToHBitmap(HDC hDC, ILuint slice);
      void	 ilutFreePaddedData(ILubyte *Data);
      void	 ilutGetBmpInfo(BITMAPINFO *Info);
      HPALETTE	 ilutGetHPal(void);
      ILubyte*	 ilutGetPaddedData(void);
      ILboolean	 ilutGetWinClipboard(void);
      ILboolean	 ilutLoadResource(HINSTANCE hInst, ILint ID, ILstring ResourceType, ILenum Type);
      ILboolean	 ilutSetHBitmap(HBITMAP Bitmap);
      ILboolean	 ilutSetHPal(HPALETTE Pal);
      ILboolean	 ilutSetWinClipboard(void);
      HBITMAP	 ilutWinLoadImage(ILstring FileName, HDC hDC);
      ILboolean	 ilutWinLoadUrl(ILstring Url);
      ILboolean  ilutWinPrint(ILuint XPos, ILuint YPos, ILuint Width, ILuint Height, HDC hDC);
      ILboolean	 ilutWinSaveImage(ILstring FileName, HBITMAP Bitmap);

      //	void	 ilutD3D8MipFunc(ILuint NumLevels);
      struct IDirect3DTexture8*  ilutD3D8Texture(struct IDirect3DDevice8 *Device);
      struct IDirect3DVolumeTexture8*  ilutD3D8VolumeTexture(struct IDirect3DDevice8 *Device);
      ILboolean	 ilutD3D8TexFromFile(struct IDirect3DDevice8 *Device, char *FileName, struct IDirect3DTexture8 **Texture);
      ILboolean	 ilutD3D8VolTexFromFile(struct IDirect3DDevice8 *Device, char *FileName, struct IDirect3DVolumeTexture8 **Texture);
      ILboolean	 ilutD3D8TexFromFileInMemory(struct IDirect3DDevice8 *Device, void *Lump, ILuint Size, struct IDirect3DTexture8 **Texture);
      ILboolean	 ilutD3D8VolTexFromFileInMemory(struct IDirect3DDevice8 *Device, void *Lump, ILuint Size, struct IDirect3DVolumeTexture8 **Texture);
      ILboolean	 ilutD3D8TexFromFileHandle(struct IDirect3DDevice8 *Device, ILHANDLE File, struct IDirect3DTexture8 **Texture);
      ILboolean	 ilutD3D8VolTexFromFileHandle(struct IDirect3DDevice8 *Device, ILHANDLE File, struct IDirect3DVolumeTexture8 **Texture);
      // These two are not tested yet.
      ILboolean  ilutD3D8TexFromResource(struct IDirect3DDevice8 *Device, HMODULE SrcModule, char *SrcResource, struct IDirect3DTexture8 **Texture);
      ILboolean  ilutD3D8VolTexFromResource(struct IDirect3DDevice8 *Device, HMODULE SrcModule, char *SrcResource, struct IDirect3DVolumeTexture8 **Texture);
      ILboolean  ilutD3D8LoadSurface(struct IDirect3DDevice8 *Device, struct IDirect3DSurface8 *Surface);

      void   ilutD3D9MipFunc(ILuint NumLevels);
      struct IDirect3DTexture9*        ilutD3D9Texture         (struct IDirect3DDevice9* Device);
      struct IDirect3DVolumeTexture9*  ilutD3D9VolumeTexture   (struct IDirect3DDevice9* Device);
      struct IDirect3DCubeTexture9*        ilutD3D9CubeTexture (struct IDirect3DDevice9* Device);

      ILboolean  ilutD3D9CubeTexFromFile(struct IDirect3DDevice9 *Device, ILconst_string FileName, struct IDirect3DCubeTexture9 **Texture);
      ILboolean  ilutD3D9CubeTexFromFileInMemory(struct IDirect3DDevice9 *Device, void *Lump, ILuint Size, struct IDirect3DCubeTexture9 **Texture);
      ILboolean  ilutD3D9CubeTexFromFileHandle(struct IDirect3DDevice9 *Device, ILHANDLE File, struct IDirect3DCubeTexture9 **Texture);
      ILboolean  ilutD3D9CubeTexFromResource(struct IDirect3DDevice9 *Device, HMODULE SrcModule, ILconst_string SrcResource, struct IDirect3DCubeTexture9 **Texture);

      ILboolean	 ilutD3D9TexFromFile(struct IDirect3DDevice9 *Device, ILconst_string FileName, struct IDirect3DTexture9 **Texture);
      ILboolean	 ilutD3D9VolTexFromFile(struct IDirect3DDevice9 *Device, ILconst_string FileName, struct IDirect3DVolumeTexture9 **Texture);
      ILboolean	 ilutD3D9TexFromFileInMemory(struct IDirect3DDevice9 *Device, void *Lump, ILuint Size, struct IDirect3DTexture9 **Texture);
      ILboolean	 ilutD3D9VolTexFromFileInMemory(struct IDirect3DDevice9 *Device, void *Lump, ILuint Size, struct IDirect3DVolumeTexture9 **Texture);
      ILboolean	 ilutD3D9TexFromFileHandle(struct IDirect3DDevice9 *Device, ILHANDLE File, struct IDirect3DTexture9 **Texture);
      ILboolean	 ilutD3D9VolTexFromFileHandle(struct IDirect3DDevice9 *Device, ILHANDLE File, struct IDirect3DVolumeTexture9 **Texture);

      // These three are not tested yet.
      ILboolean  ilutD3D9TexFromResource(struct IDirect3DDevice9 *Device, HMODULE SrcModule, ILconst_string SrcResource, struct IDirect3DTexture9 **Texture);
      ILboolean  ilutD3D9VolTexFromResource(struct IDirect3DDevice9 *Device, HMODULE SrcModule, ILconst_string SrcResource, struct IDirect3DVolumeTexture9 **Texture);
      ILboolean  ilutD3D9LoadSurface(struct IDirect3DDevice9 *Device, struct IDirect3DSurface9 *Surface);

      ID3D10Texture2D*  ilutD3D10Texture(ID3D10Device *Device);
      ILboolean  ilutD3D10TexFromFile(ID3D10Device *Device, ILconst_string FileName, ID3D10Texture2D **Texture);
      ILboolean  ilutD3D10TexFromFileInMemory(ID3D10Device *Device, void *Lump, ILuint Size, ID3D10Texture2D **Texture);
      ILboolean  ilutD3D10TexFromResource(ID3D10Device *Device, HMODULE SrcModule, ILconst_string SrcResource, ID3D10Texture2D **Texture);
      ILboolean  ilutD3D10TexFromFileHandle(ID3D10Device *Device, ILHANDLE File, ID3D10Texture2D **Texture);

      XImage *  ilutXCreateImage( Display* );
      Pixmap  ilutXCreatePixmap( Display*,Drawable );
      XImage *  ilutXLoadImage( Display*,char* );
      Pixmap  ilutXLoadPixmap( Display*,Drawable,char* );
      XImage *  ilutXShmCreateImage( Display*,XShmSegmentInfo* );
      void  ilutXShmDestroyImage( Display*,XImage*,XShmSegmentInfo* );
      Pixmap  ilutXShmCreatePixmap( Display*,Drawable,XShmSegmentInfo* );
      void  ilutXShmFreePixmap( Display*,Pixmap,XShmSegmentInfo* );
      XImage *  ilutXShmLoadImage( Display*,char*,XShmSegmentInfo* );
      Pixmap  ilutXShmLoadPixmap( Display*,Drawable,char*,XShmSegmentInfo* );
]]

