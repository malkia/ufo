-- The following can open some of the installed Apple DLL's on your Windows machine
-- and later execute code from them. Docs are online
-- Kind of nifty that you can just give this to anyone, and if they have luajit.exe they can run it!

-- Requires 32-bit luajit
assert( jit and jit.arch == "x86" and jit.os == "Windows")

local ffi = require( "ffi" )

-- http://developer.apple.com/library/mac/#documentation/GraphicsImaging/Reference/CGAffineTransform/Reference/reference.html
ffi.cdef[[
	typedef float CGFloat;
	typedef struct {
	  CGFloat a, b, c, d;
	  CGFloat tx, ty;
	} CGAffineTransform;
	CGAffineTransform CGAffineTransformMakeRotation(CGFloat angle);	
]]

-- Have iTunes, Safari or QuickTime, etc. installed for Windows! (Not sure who installed the Apple Application Support)
local commonProgramFiles = os.getenv("CommonProgramFiles") or os.getenv("CommonProgramFiles(x86)")
local appleSupportFolder = commonProgramFiles.."\\Apple\\Apple Application Support\\"

-- Either set the working directory so that CoreGraphics.dll would be able to find the rest of the DLLS
-- Or add (not done) that path to the PATH environment (ahem, it's not exposed in the "os" module, but now that FFI is here it's doable)
kernel32 = ffi.load( "KERNEL32" )
ffi.cdef("void SetCurrentDirectoryA(const char* dir);")
kernel32.SetCurrentDirectoryA( appleSupportFolder )

cg = ffi.load( "CoreGraphics.dll" )

for a=0,360,22 do
	local a = cg.CGAffineTransformMakeRotation(a)
	print( a.a, a.b, a.c, a.d, a.tx, a.ty )
end
