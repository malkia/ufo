local ffi = require( "ffi" )
local ext = {}
local cl = nil

function ext.GetPlatforms()
   local platforms, n_platforms = {}, ffi.new( "cl_uint[1]" )
   if cl.clGetPlatformIDs( 0, nil, n_platforms ) == cl.CL_SUCCESS then
      local n_platforms = n_platforms[0]
      local platform_ids = ffi.new( "cl_platform_id[?]", n_platforms )
      if cl.clGetPlatformIDs( n_platforms, platform_ids, nil ) == cl.CL_SUCCESS then
	 local size = ffi.new( "size_t[1]" )
	 for i = 0, n_platforms - 1 do
	    local prop = { id = platform_ids[i] }
	    for _, key in ipairs { "name", "vendor", "version", "profile", "extensions" } do 
	       local info_key = cl[ "CL_PLATFORM_" .. key:upper() ]
	       if cl.clGetPlatformInfo( prop.id, info_key, 0, nil, size ) == cl.CL_SUCCESS then
		  local value_size = size[0]
		  local value = ffi.new( "char[?]", value_size )
		  if cl.clGetPlatformInfo( prop.id, info_key, value_size, value, size ) == cl.CL_SUCCESS then
		     assert( value_size == size[0] )
		     local value = ffi.string( value, value_size - 1 )
		     if key == "extensions" then
			local p = {}
			for extension in value:gmatch( "%S+" ) do
			   p[#p + 1] = extension
			end
			value = p
		     end
		     prop[key] = value
		  end
	       end
	    end
	    platforms[#platforms+1] = prop
	 end
      end
   end
   return platforms
end

function ext.GetDevices(platform_id)
   local plist = {}
   local num_devices = ffi.new( "cl_uint[1]" )
   if cl.clGetDeviceIDs(platform_id, cl.CL_DEVICE_TYPE_ALL, 0, nil, num_devices ) == cl.CL_SUCCESS then
      local num_devices = num_devices[0]
      local devices = ffi.new( "cl_device_id[?]", num_devices )
      if cl.clGetDeviceIDs(platform_id, cl.CL_DEVICE_TYPE_ALL, num_devices, devices, nil) == cl.CL_SUCCESS
      then
	 for i = 0, num_devices-1
	 do
	    local prop = { id = devices[i] }
	    for k,type in pairs {
	       type                          = "cl_device_type",
	       vendor_id                     = "cl_uint",
	       max_compute_units             = "cl_uint",  max_work_item_dimensions      = "cl_uint",
	       max_work_item_sizes           = "size_t",   max_work_group_size           = "size_t",
	       preferred_vector_width_char   = "cl_uint",  preferred_vector_width_short  = "cl_uint",
	       preferred_vector_width_int    = "cl_uint",  preferred_vector_width_long   = "cl_uint",
	       preferred_vector_width_float  = "cl_uint",  preferred_vector_width_double = "cl_uint",
	       preferred_vector_width_half   = "cl_uint",
	       native_vector_width_char      = "cl_uint",  native_vector_width_short     = "cl_uint",
	       native_vector_width_int       = "cl_uint",  native_vector_width_long      = "cl_uint",
	       native_vector_width_float     = "cl_uint",  native_vector_width_double    = "cl_uint",
	       native_vector_width_half      = "cl_uint",
	       max_clock_frequency           = "cl_uint",  address_bits                  = "cl_uint",
	       max_mem_alloc_size            = "cl_ulong", image_support                 = "cl_bool",
	       max_read_image_args           = "cl_uint",  max_write_image_args          = "cl_uint",
	       image2d_max_width             = "size_t",   image2d_max_height            = "size_t",
	       image3d_max_width             = "size_t",   image3d_max_height            = "size_t",
	       image3d_max_depth             = "size_t",
	       max_samplers                  = "cl_uint",  max_parameter_size            = "size_t",
	       mem_base_addr_align           = "cl_uint",  min_data_type_align_size      = "cl_uint",
	       single_fp_config              = "cl_device_fp_config",
	       double_fp_config              = "cl_device_fp_config",
	       half_fp_config                = "cl_device_fp_config",
	       global_mem_cache_type         = "cl_device_mem_cache_type",
	       global_mem_cacheline_size     = "cl_uint",  global_mem_cache_size         = "cl_ulong",
	       global_mem_size               = "cl_ulong", max_constant_buffer_size      = "cl_ulong",
	       max_constant_args             = "cl_uint",  local_mem_type                = "cl_device_local_mem_type",
	       local_mem_size                = "cl_ulong", error_correction_support      = "cl_bool",
	       host_unified_memory           = "cl_bool",  profiling_timer_resolution    = "size_t",
	       endian_little                 = "cl_bool",  available                     = "cl_bool",
	       compiler_available            = "cl_bool",  execution_capabilities        = "cl_device_exec_capabilities",
	       queue_properties              = "cl_command_queue_properties",
	       platform                      = "cl_platform_id",
	       name                          = "string",   vendor                        = "string",
	       driver_version                = "string",   profile                       = "string",
	       version                       = "string",   opencl_c_version              = "string",
	       extensions                    = "string",
	    }
	    do
	       local value_enum = cl[ "CL_DEVICE_"..k:upper() ]
	       local value_size = ffi.new( "size_t[1]" )
	       if cl.clGetDeviceInfo( prop.id, value_enum, 0, nil, value_size ) == cl.CL_SUCCESS
	       then
		  local value_size = tonumber( value_size[0] )
		  local value_type = (type == "string") and "char" or type
		  local value_count = value_size / ffi.sizeof(value_type)
		  local value = ffi.new( value_type.."[?]", value_count )
		  if cl.clGetDeviceInfo( prop.id, value_enum, value_size, value, nil ) == cl.CL_SUCCESS
		  then
		     if type == "string" then
			local value = ffi.string( value, value_size - 1 )
			if k == "extensions" then
			   local p = {}
			   for extension in value:gmatch( "%S+" ) do
			      p[#p + 1] = extension
			   end
			   value = p
			end
			prop[k] = value
		     else
		        if value_count > 1 
			then
			  prop[k] = {}
			  for i = 0, value_count - 1 do
			    local ok, v = pcall(tonumber, value[i])
			    prop[k][i+1] = ok and v or value[i]
			  end
			else
			  local ok, v = pcall(tonumber, value[0])
			  prop[k] = ok and v or value[0]
			end
		     end
		  end
	       end
	    end
	    plist[#plist+1] = prop
	 end
      end
   end
   return plist
end

function ext.EncodeContextProperties(properties)
   local count = #properties
   local props = ffi.new( "cl_context_properties[?]", count )
   local index = 0
   for k,v in pairs(properties) do
      props[ index * 2 + 0 ] = cl[ "CL_CONTEXT_"..k:upper() ]
      props[ index * 2 + 1 ] = ffi.cast( "cl_context_properties", v )
      index = index + 2
   end
   props[ index * 2 ] = ffi.cast( "cl_context_properties", nil )
   return props
end

function ext.DecodeContextProperties(properties)
   local props = {}
   local count = ffi.sizeof( properties ) / ffi.sizeof( "cl_context_properties" )
   for index=0, count-1, 2 do
      local key = properties[ key * 2 + 0 ]
      local val = properties[ key * 2 + 1 ]
   end
   return props
end

function ext.GetContextInfo(context)
   local plist = {}
   for key, type in pairs {
      reference_count = "cl_uint",  
      num_devices     = "cl_uint",
      devices         = "cl_device_id",
      properties      = "cl_context_properties"
   }
   do
      local value_enum = cl[ "CL_CONTEXT_"..key:upper() ]
      local value_size = ffi.new( "size_t[1]" )
      if cl.clGetContextInfo( context, value_enum, 0, nil, value_size ) == cl.CL_SUCCESS
      then
	 local value_size = tonumber( value_size[0] )
	 local value_count = value_size / ffi.sizeof(type)
	 local value = ffi.new( type.."[?]", value_count )
	 if cl.clGetContextInfo( context, value_enum, value_size, value, nil ) == cl.CL_SUCCESS
	 then
	    if value_count > 1 
	    then
	       plist[key] = {}
	       for i = 0, value_count - 1 do
		  local ok, v = pcall(tonumber, value[i])
		  plist[key][i+1] = ok and v or value[i]
	       end
	    else
	       local ok, v = pcall(tonumber, value[0])
	       plist[key] = ok and v or value[0]
	    end
	 end
      end
   end
   return plist
end

function ext.GetKernelWorkGroupInfo(kernel, device)
   local plist = {}
   for key, type in pairs {
      work_group_size                    = "size_t",
      compile_work_group_size            = "size_t",
      local_mem_size                     = "cl_ulong",
      preferred_work_group_size_multiple = "size_t",
      private_mem_size                   = "cl_ulong",
   }
   do
      local value_enum = cl[ "CL_KERNEL_"..key:upper() ]
      local value_size = ffi.new( "size_t[1]" )
      if cl.clGetKernelWorkGroupInfo( context, device, value_enum, 0, nil, value_size ) == cl.CL_SUCCESS
      then
	 local value_size = tonumber( value_size[0] )
	 local value_count = value_size / ffi.sizeof(type)
	 local value = ffi.new( type.."[?]", value_count )
	 if cl.clGetKernelWorkGroupInfo( context, device, value_enum, value_size, value, nil ) == cl.CL_SUCCESS
	 then
	    if value_count > 1 
	    then
	       plist[key] = {}
	       for i = 0, value_count - 1 do
		  local ok, v = pcall(tonumber, value[i])
		  plist[key][i+1] = ok and v or value[i]
	       end
	    else
	       local ok, v = pcall(tonumber, value[0])
	       plist[key] = ok and v or value[0]
	    end
	 end
      end
   end
   return plist
end

return function( ffi_OpenCL )
	  cl = ffi_OpenCL or require( "ffi/OpenCL" )
	  return ext
       end
