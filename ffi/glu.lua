local ffi  = require( "ffi" )

local libs = ffi_glu_libs or {
   OSX     = { x86 = "OpenGL.framework/OpenGL", x64 = "OpenGL.framework/OpenGL" },
   Windows = { x86 = "GLU32.DLL",               x64 = "GLU32.DLL"               },
   Linux   = { x86 = "libGLU.so",               x64 = "libGLU.so", arm = "libGLU.so" },
   BSD     = { x86 = "libGLU.so",               x64 = "libGLU.so"               },
   POSIX   = { x86 = "libGLU.so",               x64 = "libGLU.so"               },
   Other   = { x86 = "libGLU.so",               x64 = "libGLU.so"               },
}

local lib  = ffi_glu_lib or libs[ ffi.os ][ ffi.arch ]

local glu  = ffi.load( lib )

ffi.cdef[[
typedef struct GLUnurbs      GLUnurbs;
typedef struct GLUquadric    GLUquadric;
typedef struct GLUtesselator GLUtesselator;
typedef struct GLUnurbs      GLUnurbsObj;
typedef struct GLUquadric    GLUquadricObj;
typedef struct GLUtesselator GLUtesselatorObj;
typedef struct GLUtesselator GLUtriangulatorObj;
void           gluBeginCurve (GLUnurbs* nurb);
void           gluBeginPolygon (GLUtesselator* tess);
void           gluBeginSurface (GLUnurbs* nurb);
void           gluBeginTrim (GLUnurbs* nurb);
GLint          gluBuild1DMipmapLevels (GLenum target, GLint internalFormat, GLsizei width, GLenum format, GLenum type, GLint level, GLint base, GLint max, const void *data);
GLint          gluBuild1DMipmaps (GLenum target, GLint internalFormat, GLsizei width, GLenum format, GLenum type, const void *data);
GLint          gluBuild2DMipmapLevels (GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLenum format, GLenum type, GLint level, GLint base, GLint max, const void *data);
GLint          gluBuild2DMipmaps (GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLenum format, GLenum type, const void *data);
GLint          gluBuild3DMipmapLevels (GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, GLint level, GLint base, GLint max, const void *data);
GLint          gluBuild3DMipmaps (GLenum target, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void *data);
GLboolean      gluCheckExtension (const GLubyte *extName, const GLubyte *extString);
void           gluCylinder (GLUquadric* quad, GLdouble base, GLdouble top, GLdouble height, GLint slices, GLint stacks);
void           gluDeleteNurbsRenderer (GLUnurbs* nurb);
void           gluDeleteQuadric (GLUquadric* quad);
void           gluDeleteTess (GLUtesselator* tess);
void           gluDisk (GLUquadric* quad, GLdouble inner, GLdouble outer, GLint slices, GLint loops);
void           gluEndCurve (GLUnurbs* nurb);
void           gluEndPolygon (GLUtesselator* tess);
void           gluEndSurface (GLUnurbs* nurb);
void           gluEndTrim (GLUnurbs* nurb);
const GLubyte* gluErrorString (GLenum error);
void           gluGetNurbsProperty (GLUnurbs* nurb, GLenum property, GLfloat* data);
const GLubyte* gluGetString (GLenum name);
void           gluGetTessProperty (GLUtesselator* tess, GLenum which, GLdouble* data);
void           gluLoadSamplingMatrices (GLUnurbs* nurb, const GLfloat *model, const GLfloat *perspective, const GLint *view);
void           gluLookAt (GLdouble eyeX, GLdouble eyeY, GLdouble eyeZ, GLdouble centerX, GLdouble centerY, GLdouble centerZ, GLdouble upX, GLdouble upY, GLdouble upZ);
GLUnurbs*      gluNewNurbsRenderer (void);
GLUquadric*    gluNewQuadric (void);
GLUtesselator* gluNewTess (void);
void           gluNextContour (GLUtesselator* tess, GLenum type);
void           gluNurbsCallback (GLUnurbs* nurb, GLenum which, GLvoid (*CallBackFunc)());
void           gluNurbsCallbackData (GLUnurbs* nurb, GLvoid* userData);
void           gluNurbsCallbackDataEXT (GLUnurbs* nurb, GLvoid* userData);
void           gluNurbsCurve (GLUnurbs* nurb, GLint knotCount, GLfloat *knots, GLint stride, GLfloat *control, GLint order, GLenum type);
void           gluNurbsProperty (GLUnurbs* nurb, GLenum property, GLfloat value);
void           gluNurbsSurface (GLUnurbs* nurb, GLint sKnotCount, GLfloat* sKnots, GLint tKnotCount, GLfloat* tKnots, GLint sStride, GLint tStride, GLfloat* control, GLint sOrder, GLint tOrder, GLenum type);
void           gluOrtho2D (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top);
void           gluPartialDisk (GLUquadric* quad, GLdouble inner, GLdouble outer, GLint slices, GLint loops, GLdouble start, GLdouble sweep);
void           gluPerspective (GLdouble fovy, GLdouble aspect, GLdouble zNear, GLdouble zFar);
void           gluPickMatrix (GLdouble x, GLdouble y, GLdouble delX, GLdouble delY, GLint *viewport);
GLint          gluProject (GLdouble objX, GLdouble objY, GLdouble objZ, const GLdouble *model, const GLdouble *proj, const GLint *view, GLdouble* winX, GLdouble* winY, GLdouble* winZ);
void           gluPwlCurve (GLUnurbs* nurb, GLint count, GLfloat* data, GLint stride, GLenum type);
void           gluQuadricCallback (GLUquadric* quad, GLenum which, GLvoid (*CallBackFunc)());
void           gluQuadricDrawStyle (GLUquadric* quad, GLenum draw);
void           gluQuadricNormals (GLUquadric* quad, GLenum normal);
void           gluQuadricOrientation (GLUquadric* quad, GLenum orientation);
void           gluQuadricTexture (GLUquadric* quad, GLboolean texture);
GLint          gluScaleImage (GLenum format, GLsizei wIn, GLsizei hIn, GLenum typeIn, const void *dataIn, GLsizei wOut, GLsizei hOut, GLenum typeOut, GLvoid* dataOut);
void           gluSphere (GLUquadric* quad, GLdouble radius, GLint slices, GLint stacks);
void           gluTessBeginContour (GLUtesselator* tess);
void           gluTessBeginPolygon (GLUtesselator* tess, GLvoid* data);
void           gluTessCallback (GLUtesselator* tess, GLenum which, GLvoid (*CallBackFunc)());
void           gluTessEndContour (GLUtesselator* tess);
void           gluTessEndPolygon (GLUtesselator* tess);
void           gluTessNormal (GLUtesselator* tess, GLdouble valueX, GLdouble valueY, GLdouble valueZ);
void           gluTessProperty (GLUtesselator* tess, GLenum which, GLdouble data);
void           gluTessVertex (GLUtesselator* tess, GLdouble *location, GLvoid* data);
GLint          gluUnProject (GLdouble winX, GLdouble winY, GLdouble winZ, const GLdouble *model, const GLdouble *proj, const GLint *view, GLdouble* objX, GLdouble* objY, GLdouble* objZ);
GLint          gluUnProject4 (GLdouble winX, GLdouble winY, GLdouble winZ, GLdouble clipW, const GLdouble *model, const GLdouble *proj, const GLint *view, GLdouble nearPlane, GLdouble farPlane, GLdouble* objX, GLdouble* objY, GLdouble* objZ, GLdouble* objW);
]]

return glu
