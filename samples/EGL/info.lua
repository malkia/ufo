local ffi = require( "ffi" )
local egl = require( "ffi/EGL" )

local function main()
  local dpy = egl.eglGetDisplay( egl.EGL_DEFAULT_DISPLAY )
  assert( dpy ~= nil, "eglGetDisplay returned nil" )
  local major, minor = ffi.new( "EGLint[1]" ), ffi.new( "EGLint[1]" )
  local ok = egl.eglInitialize(dpy, major, minor)
  assert( ok ~= egl.EGL_FALSE, "eglInitialize failed" )
  major, minor = major[0], minor[0]
  local vendor = egl.eglQueryString(dpy, egl.EGL_VENDOR)
  assert( vendor ~= nil, "eqlQueryString failed" )
  vendor = ffi.string(vendor)
  print( "EGL_VENDOR = " .. vendor .. ", version " .. tostring(major) .. "." .. tostring(minor) )
  print()
  local n_cfg = ffi.new("EGLint[1]")
  local ok = egl.eglGetConfigs( dpy, nil, 0, n_cfg )
  assert( ok, "eglGetConfigs(1) failed" )
  local n_cfg2 = n_cfg[0]
  local cfg = ffi.new( "EGLConfig[?]", n_cfg2 )
  local ok = egl.eglGetConfigs( dpy, cfg, n_cfg2, n_cfg )
  local n_cfg = n_cfg[0]
  assert( ok ~= egl.EGL_FALSE, "eglGetConfigs(2) failed")
  assert( n_cfg2 == n_cfg, "eglGetConfigs(3) - mismatch of returned number of configs" )
  local value = ffi.new( "EGLint[1]" )
  local fmt = string.format
  local details = {
     [egl.EGL_CONFIG_CAVEAT] = {
         [egl.EGL_NONE] = "Normal",
	 [egl.EGL_SLOW_CONFIG] = "Slow",
	 [egl.EGL_NON_CONFORMANT_CONFIG] = "Non-conformant"
     },
     [egl.EGL_COLOR_BUFFER_TYPE] = {
         [egl.EGL_RGB_BUFFER] = "RGB color buffer",
	 [egl.EGL_LUMINANCE_BUFFER] = "Luminance buffer"
     },
     [egl.EGL_SURFACE_TYPE] = {
     	[0]="None!",
	[1]="PBuffer",
	[2]="Pixmap",
	[3]="PBuffer+Pixmap",
	[4]="Window",
	[5]="Window+PBuffer",
	[6]="Window+Pixmap",
	[7]="Window+Pixmap+PBuffer",
	mask = 7,
     },
     [egl.EGL_RENDERABLE_TYPE] = {
	[0]="No API support(?)",
	[1]="OpenGL ES",
	[2]="OpenVG",
	[3]="OpenGL ES, OpenVG",
	[4]="OpenGL ES2",
	[5]="OpenGL ES, OpenGL ES2",
	[6]="OpenGL ES2, OpenVG",
	[7]="OpenGL ES, OpenGL ES2, OpenVG",
	mask = 7,
     },
  }
  for i=0, n_cfg-1 do
    for _,k in ipairs{
        "BUFFER_SIZE", "ALPHA_SIZE", "BLUE_SIZE", "GREEN_SIZE", "RED_SIZE", "DEPTH_SIZE", "STENCIL_SIZE", "LUMINANCE_SIZE",
	"ALPHA_MASK_SIZE", "BIND_TO_TEXTURE_RGB", "BIND_TO_TEXTURE_RGBA", "COLOR_BUFFER_TYPE", "CONFORMANT",
        "CONFIG_CAVEAT", "CONFIG_ID", "LEVEL", "MAX_PBUFFER_HEIGHT", "MAX_PBUFFER_PIXELS", "MAX_PBUFFER_WIDTH",
	"NATIVE_RENDERABLE", "NATIVE_VISUAL_ID", "NATIVE_VISUAL_TYPE", "SAMPLES", "SAMPLE_BUFFERS", "SURFACE_TYPE",
	"TRANSPARENT_TYPE", "TRANSPARENT_BLUE_VALUE", "TRANSPARENT_GREEN_VALUE", "TRANSPARENT_RED_VALUE",
	"RENDERABLE_TYPE", "MAX_SWAP_INTERVAL", "MIN_SWAP_INTERVAL", "MATCH_NATIVE_PIXMAP"  }
    do
      local K = egl["EGL_"..k:upper()]
      local ok = egl.eglGetConfigAttrib(dpy, cfg[i], K, value)
      if ok ~= egl.EGL_FALSE then
         local value = value[0]
	 local details = details[K]
	 local details = details and details[bit.band(value, details.mask or 0xFFFF)]
	 local details = details and (" ("..details..")") or ""
         print( fmt("%02.2d",i).." "..fmt("%-23s",k).." = "..value..details )
      else
         print( fmt("%02.2d",i).." "..fmt("%-23s",k).." ERROR: 0x"..fmt("%X",egl.eglGetError()))
      end
    end
    print()
  end
  egl.eglTerminate(dpy)
end

main()
