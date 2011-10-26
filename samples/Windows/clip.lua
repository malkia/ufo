-- pbpaste (Mac OS X) program for Windows
-- to run: luajit winclip.lua
-- it should print the clipboard (textual content)
local ffi = require( "ffi" )

ffi.cdef[[
enum { CF_TEXT = 1 };
int      OpenClipboard(void*);
void*    GetClipboardData(unsigned);
int      CloseClipboard();
void*    GlobalLock(void*);
int      GlobalUnlock(void*);
size_t   GlobalSize(void*);
]]

local ok1    = ffi.C.OpenClipboard(nil)
local handle = ffi.C.GetClipboardData( ffi.C.CF_TEXT )
local size   = ffi.C.GlobalSize( handle )
local mem    = ffi.C.GlobalLock( handle )
local text   = ffi.string( mem, size )
local ok     = ffi.C.GlobalUnlock( handle )
local ok3    = ffi.C.CloseClipboard()

print(text)
