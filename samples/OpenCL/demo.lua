#!/usr/bin/env luajit

local ffi = require( "ffi" )
local cl  = require( "ffi/OpenCL" )
local clx = require( "lib/OpenCL" )( cl )
local cl_error = 0
local cl_error_buf = ffi.new( "int[1]" )

local source = [[
      __kernel void square(__global const float* input, __global float* output, const unsigned int count)
      {                                            
	 int i = get_global_id(0);
	 if( i < count )                 
	     output[i] = input[i] * input[i];
      }
]]

function clEnqueueNDRangeKernel(queue, kernel, global_offsets, global_sizes, local_sizes)
   local dim = #global_sizes
   if (global_offsets ~= nil and dim ~= #global_offsets) or dim ~= #local_sizes then
      error( "clEnqueueNDRangeKernel: global_sizes must have the same dimension of local_sizes and global_offsets, unless global_offsets is nil" )
   end
   local gwo
   if #global_offsets ~= nil then
      gwo = ffi.new( "size_t[?]", dim, global_offsets )
   end
   local gws = ffi.new( "size_t[?]", dim, global_sizes )
   local lws = ffi.new( "size_t[?]", dim, local_sizes )
   local err = cl.clEnqueueNDRangeKernel(queue, kernel, dim, gwo, gws, lws, 0, nil, nil)
   if err ~= cl.CL_SUCCESS then
      error( "clEnqueueNDRangeKernel: " .. err )
   end
end

local function wrap1(func)
   return function(...)
	     local err = func(...)
	     if err ~= cl.CL_SUCCESS then
		error( "wrap1err - " .. err )
	     end
	  end
end

local errbuf = ffi.new( "int[1]" )
local function wrap2(func)
   return function(...)
	     -- argc might be different than #args
	     -- for example if the last argument is nil
	     local argc = select("#", ...)
	     local args = {...}
	     args[ argc + 1 ] = errbuf
	     local res = func(unpack(args))
	     local err = errbuf[0]
	     if err ~= cl.CL_SUCCESS then
		error( "wrap2err - " .. err )
	     end
	     return res
	  end
end

clRetainContext           = wrap1(cl.clRetainContext)
clReleaseContext          = wrap1(cl.clReleaseContext)
clFinish                  = wrap1(cl.clFinish)
clReleaseMemObject        = wrap1(cl.clReleaseMemObject)
clReleaseProgram          = wrap1(cl.clReleaseProgram)
clReleaseKernel           = wrap1(cl.clReleaseKernel)
clReleaseCommandQueue     = wrap1(cl.clReleaseCommandQueue)
clReleaseContext          = wrap1(cl.clReleaseContext)
clUnloadCompiler          = wrap1(cl.clUnloadCompiler)
clCreateKernel            = wrap2(cl.clCreateKernel)
clCreateBuffer            = wrap2(cl.clCreateBuffer)
clCreateContext           = wrap2(cl.clCreateContext)
clCreateCommandQueue      = wrap2(cl.clCreateCommandQueue)
clCreateProgramWithSource = wrap2(cl.clCreateProgramWithSource)
clBuildProgram            = wrap1(cl.clBuildProgram)
clEnqueueWriteBuffer      = wrap1(cl.clEnqueueWriteBuffer)
clEnqueueReadBuffer       = wrap1(cl.clEnqueueReadBuffer)
clSetKernelArgHELPER      = wrap1(cl.clSetKernelArg)
clSetKernelArg            = function(kernel, index, data, type)
			       local data2 = ffi.new( type .. "[1]", data )
			       return clSetKernelArgHELPER(kernel, index, ffi.sizeof(data2), data2)
			    end

local function demo1( devidx )
   local devices = {}
   for platform_index, platform in pairs(clx.GetPlatforms()) do
      local platform_devices = clx.GetDevices(platform.id)
      for device_index, device in pairs(platform_devices) do
	 devices[ #devices + 1 ] = device
      end
   end

   local ffi_devices = ffi.new( "cl_device_id[?]", #devices )
   for k, _ in ipairs( devices ) do
      ffi_devices[k-1] = devices[ k ].id
      print( devices[k].id )
   end

   devidx = 1
   print( "You chose device index " .. devidx .. " of [0.." .. #devices - 1 .. "]" )
   if devidx < 0 or devidx >= #devices then
      error( "ERROR: ".. #devices .. " devices found. Choose from 0.." .. #devices - 1 .. "!" )
   end
   local ffi_device = ffi.new( "cl_device_id[1]", ffi_devices[devidx] )
   local err = ffi.new( "int[1]" )
   local context_properties = ffi.new( "cl_context_properties[3]", 
				       cl.CL_CONTEXT_PLATFORM, 
				       ffi.cast("intptr_t",devices[devidx+1].platform),
				       ffi.cast("intptr_t", nil))
   local context = clCreateContext(context_properties, 1, ffi_device, nil, nil)

   print( "CONTEXT ", context )
   print( "" )

   local context_info = clGetContextInfo(context)
   print( "CONTEXT_INFO = ", context_info )
   for k,v in pairs(context_info) do print("CONTEXT_INFO : ", k," = ", v) end
   print( "")

   local queue = clCreateCommandQueue(context, ffi_device[0], 0)

   print( "QUEUE ", queue )

   local src = ffi.new("char[?]", #source+1, source)
   local src2 = ffi.new("const char*[1]", src)
   local program = clCreateProgramWithSource(context, 1, src2, nil)
   clBuildProgram( program, 0, nil, nil, nil, nil )
   local kernel = clCreateKernel(program, "square")

   local count = 1024
   local data = ffi.new("float[?]", count)
   for i=0,count-1 do data[i] = (i + 10) end

   local input  = clCreateBuffer(context, cl.CL_MEM_READ_ONLY,  ffi.sizeof(data), nil)
   local output = clCreateBuffer(context, cl.CL_MEM_WRITE_ONLY, ffi.sizeof(data), nil)

   clEnqueueWriteBuffer(queue, input, cl.CL_TRUE, 0, ffi.sizeof(data), data, 0, nil, nil)
   clSetKernelArg(kernel, 0, input, "cl_mem")
   clSetKernelArg(kernel, 1, output, "cl_mem")
   clSetKernelArg(kernel, 2, count, "int")

   local work_group_info = clGetKernelWorkGroupInfo( kernel, ffi_device[0] )
   local work_group_size = work_group_info.work_group_size
--   clEnqueueNDRangeKernel( queue, kernel, nil, { count }, work_group_info.work_group_size )
   clFinish( queue )

   local results = ffi.new("float[?]", count)
   clEnqueueReadBuffer(queue, output, cl.CL_TRUE, 0, ffi.sizeof(results), results, 0, nil, nil)

--   for i=0,count-1 do
--      io.stdout:write(results[i])
--      io.stdout:write('\t')
   --   end
--   io.stdout:write("\n")

   clReleaseMemObject(     input  )
   clReleaseMemObject(    output  )
   clReleaseProgram(      program )
   clReleaseKernel(       kernel  )
   clReleaseCommandQueue( queue   )
   clReleaseContext(      context )

   print( "END!" )
end

demo1(0)

