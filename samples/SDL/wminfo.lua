local ffi = require( "ffi" )
local sdl = require( "ffi/SDL" )

local screen = sdl.SDL_SetVideoMode( 640, 480, 32, 0 )
local wminfo = ffi.new( "SDL_SysWMinfo" )
sdl.SDL_GetVersion( wminfo.version )
local result = sdl.SDL_GetWMInfo( wminfo )
print( wminfo.subsystem )
sdl.SDL_Quit()
