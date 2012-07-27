-- jucit - Just compile it!

local function readRegistry(key, value, type)
   local type = type or 'REG_SZ'
   local sysroot = assert(os.getenv('SystemRoot'))
   for _, reg in ipairs{"\\syswow64\\reg.exe", "\\system32\\reg.exe"} do
      for k,v in assert(io.popen(sysroot..reg..' QUERY "'..key..'" /v "'..value..'" 2>nul')):lines() do
	 local data
	 string.gsub(
	    k, "%s+(%S+)%s+(%S+)%s+(.+)",
	    function(v,t,d) data = value==v and type==t and d or data end)
	 if data ~= nil then
	    return data
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
   xbox360 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Xbox\\2.0\\SDK',
      'InstallPath'
   },
   webos = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\HP webOS\\SDK',
      'InstallDir'
   },
   sourcery_gcc = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\'..
	 'Sourcery G++ Lite for ARM GNU/Linux',
      'InstallLocation'
   },
   cygwin = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Cygwin\\setup',
      'rootdir'
   },
   bbndk_10_04_beta = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\'..
	 'BlackBerry 10 Native SDK 10.0.4-beta',
      'InstallLocation'
   },
   bbndk_2_00 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\'..
	 'BlackBerry Native SDK for Tablet OS 2.0.0',
      'InstallLocation'
   },
   bbndk_2_00 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\'..
	 'BlackBerry Native SDK for Tablet OS 2.0.0',
      'InstallLocation'
   },
   bbndk_2_01 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\'..
	 'BlackBerry Native SDK for Tablet OS 2.0.1',
      'InstallLocation'
   },
   bbndk_2_10_beta1 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\'..
	 'BlackBerry Native SDK for Tablet OS 2.1.0-beta1',
      'InstallLocation'
   },
   msvc8 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\8.0\\Setup\\VC',
      'ProductDir'
   },
   msvc9 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\9.0\\Setup\\VC',
      'ProductDir'
   },
   msvc10 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\10.0\\Setup\\VC',
      'ProductDir'
   },
   msvc11 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\11.0\\Setup\\VC',
      'ProductDir'
   },
   dia8 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\SxS\\DIA_SDK',
      '8.0'
   },
   dia9 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\SxS\\DIA_SDK',
      '9.0'
   },
   dia10 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\SxS\\DIA_SDK',
      '10.0'
   },
   dia11 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\VisualStudio\\SxS\\DIA_SDK',
      '11.0'
   },
   wdk8 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\WDK',
      'WDKContentRoot'
   },
   nvidia_gpusdk_40 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\NVIDIA Corporation\\Installed Products\\'..
	 'NVIDIA GPU Computing SDK 4.0',
      'InstallDir',
   },
   nvidia_gpusdk_41 = {
      'HKEY_LOCAL_MACHINE\\SOFTWARE\\NVIDIA Corporation\\Installed Products\\'..
	 'NVIDIA GPU Computing SDK 4.1',
      'InstallDir',
   },
}

print()
for k,v in pairs(sdks) do
   print( k, readRegistry( v[1], v[2] ))
end
