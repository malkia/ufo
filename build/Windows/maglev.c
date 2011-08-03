// maglev -- malkia's GL extension vectors
// For more complete options, look at:
// GL3W, GLEW and GLEE
//
// Dimiter "malkia" Stanev
// malkia@gmail.com
//
#define WIN32_LEAN_AND_MEAN 1
#define WIN32_EXTRA_LEAN 1
#include <windows.h>
#include <GL/gl.h>
#include "GL/glext.h"

#define BOMBAX(FUNC, NAME, DEF_ARGS, CALL_ARGS) \
__declspec(dllexport) GLAPI void APIENTRY FUNC DEF_ARGS\
{\
	typedef void (APIENTRY* MAGL_PROC) DEF_ARGS;\
	static MAGL_PROC stored_proc = NULL;\
        MAGL_PROC proc = stored_proc;\
	\
	if( !proc ) {\
		proc = (MAGL_PROC) wglGetProcAddress( NAME );\
		if( !proc ) return;\
		stored_proc = proc;\
	}\
	\
	proc CALL_ARGS ;\
	if( glGetError() )\
		stored_proc = NULL;\
}\

#define BOMBA0(n)         BOMBAX(n,#n,(),())
#define BOMBA1(n,A)       BOMBAX(n,#n,(A a),(a))
#define BOMBA2(n,A,B)     BOMBAX(n,#n,(A a, B b),(a,b))
#define BOMBA3(n,A,B,C)   BOMBAX(n,#n,(A a, B b, C c),(a,b,c))
#define BOMBA4(n,A,B,C,D) BOMBAX(n,#n,(A a, B b, C c, D d),(a,b,c,d))

BOMBA1(glActiveTexture, GLenum)
BOMBA4(glBlendFuncSeparate, GLenum, GLenum, GLenum, GLenum)
