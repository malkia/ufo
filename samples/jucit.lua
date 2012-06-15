-- jucit - Just compile it!

local function readRegistry(key, value, type)
   local sysroot = assert(os.getenv('SystemRoot'))
   local type = type or 'REG_SZ'
   local look4 = '    '..value..'    '..type..'    '
   for _, reg in ipairs{ "\\syswow64\\reg.exe", "\\system32\\reg.exe" } do
      for k,v in assert(io.popen(sysroot..reg..' QUERY "'..key..'" /v "'..value..'"')):lines() do
	 if k:sub(1,look4:len()) == look4 then
	    return k:sub(look4:len()+1)
	 end
      end
   end
end

local sdks = {
   ddk71 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\KitSetup\\configured-kits\\' ..
	 '{B4285279-1846-49B4-B8FD-B9EAF0FF17DA}\\{68656B6B-555E-5459-5E5D-6363635E5F61}',
      'setup-install-location'
   },
   sdk60A = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v6.0A',
      'InstallationFolder'
   },
   sdk70 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v7.0',
      'InstallationFolder'
   },
   sdk70A = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v7.0A',
      'InstallationFolder'
   },
   sdk71 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v7.1',
      'InstallationFolder'
   },
   sdk80 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows\\v8.0',
      'InstallationFolder'
   },
}

for k,v in pairs(sdks) do
   print( k, readRegistry( v[1], v[2] ))
end

