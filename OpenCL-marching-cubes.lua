local ffi = require( "ffi" )
local gl  = require( "ffi/OpenGL" )
local cl  = require( "ffi/OpenCL" )
local fw  = require( "ffi/glfw" )
local glu = require( "ffi/glu" )
local tw  = require( "ffi/AntTweakBar" )

local kernel = [[
      __kernel void UpdateVals(__global float * Tempo, __global float * Vals)
      {
	 int x = get_global_id(0);
	 int y = get_global_id(1);
	 int z = get_global_id(2);
	 
	 int maxX = get_global_size(0);
	 int maxY = get_global_size(1);
	 int maxZ = get_global_size(2);
	 int maxXY = maxX*maxY;
	 
	 float t = 10.0f*Tempo[0];
	 float st, ct;
	 st = 0.3f*native_sin(0.4f*t);
	 
	 float xVal = 2.0f * ((float)x / (float)(maxX - 1) - 0.5f);
	 float yVal = 2.0f * ((float)y / (float)(maxY - 1) - 0.5f);
	 float zVal = 2.0f * ((float)z / (float)(maxZ - 1) - 0.5f);
	 
	 //Source 1
	 float r = (xVal-st) * (xVal-st) + yVal * yVal + zVal * zVal;
	 float val = 0.02f/r;
	 
	 //Source 2
	 st = 0.49f*native_sin(0.03f*t);
	 ct = 0.44f*native_cos(0.017f*t);
	 r = (xVal-st) * (xVal-st) + (yVal-ct) * (yVal-ct) + zVal * zVal;
	 val += 0.05f/r;
	 
	 //Source 3
	 st = 0.37f*native_sin(0.023f*t+1.0f);
	 ct = 0.51f*native_cos(0.047f*t+0.5f);
	 r = (xVal-st) * (xVal-st) + (yVal-ct) * (yVal-ct) + (zVal-st) * (zVal-st);
	 val += 0.07f/r;
	 
	 //Source 4
	 st = 0.57f*native_sin(0.027f*t+1.2f);
	 ct = 0.61f*native_cos(0.077f*t+2.3f);
	 r = (xVal-st) * (xVal-st) + (yVal-ct) * (yVal-ct) + (zVal-st) * (zVal-st);
	 val += 0.036f/r;
	 
	 //Source 5
	 st = 0.45f*native_sin(0.041f*t+3.0f);
	 ct = 0.49f*native_cos(0.097f*t+1.7f);
	 r = xVal * xVal + (yVal-ct) * (yVal-ct) + (zVal-st) * (zVal-st);
	 val += 0.026f/r;
	 
	 //Source 6
	 st = 0.4453f*native_sin(0.116341f*t+3.2f);
	 ct = 0.54357f*native_cos(0.134357f*t+4.0f);
	 r = (xVal-ct) * (xVal-ct) + (yVal-st) * (yVal-st) + (zVal-st-ct) * (zVal-st-ct);
	 val += 0.032643f/r;
	 
	 //Source 7
	 st = 0.3767f*native_sin(0.025673f*t+1.0345f);
	 ct = 0.5156f*native_cos(0.047568f*t+0.5345f);
	 r = (xVal-st) * (xVal-st) + (yVal-ct) * (yVal-ct) + (zVal-st) * (zVal-st);
	 val += 0.07456f/r;
	 
	 //Source 8
	 st = 0.5735f*native_sin(0.02723f*t+1.2f);
	 ct = 0.61654f*native_cos(0.07734f*t+2.3f);
	 r = (xVal-st) * (xVal-st) + (yVal-ct) * (yVal-ct) + (zVal-st) * (zVal-st);
	 val += 0.036234f/r;
	 
	 //Source 9
	 st = 0.45f*native_sin(0.041234f*t+3.0435f);
	 ct = 0.49f*native_cos(0.097234f*t+1.7345f);
	 r = xVal * xVal + (yVal-ct) * (yVal-ct) + (zVal-st) * (zVal-st);
	 val -= 0.026345f/r;

	 //Source 10
	 st = 0.43233f*native_sin(0.111f*t+3.2345f);
	 ct = 0.5711f*native_cos(0.137f*t+4.0345f);
	 r = (xVal-ct) * (xVal-ct) + (yVal-st) * (yVal-st) + (zVal-st-ct) * (zVal-st-ct);
	 val -= 0.032345f/r;
	 
	 //Source 1b
	 r = (xVal-st) * (xVal-st) + (yVal-ct) * (yVal-ct) + zVal * zVal;
	 val = 0.01221f/r;
	 
	 //Source 2b
	 st = 0.49f*native_sin(0.1332432f*t);
	 ct = 0.44f*native_cos(0.11932443f*t);
	 r = (xVal-st) * (xVal-st) + (yVal-ct) * (yVal-ct) + zVal * zVal;
	 val += 0.05f/r;
	 
	 //Source 3b
	 st = 0.37f*native_sin(0.123f*t-1.7f);
	 ct = 0.51f*native_cos(0.147f*t-0.7f);
	 r = (xVal-st) * (xVal-st) + (yVal-ct) * (yVal-ct) + (zVal-st) * (zVal-st);
	 val += 0.07f/r;

	 //Source 4b
	 st = 0.57f*native_sin(0.127f*t-1.7f);
	 ct = 0.61f*native_cos(0.177f*t-2.7f);
	 r = (xVal-st) * (xVal-st) + (yVal-ct) * (yVal-ct) + (zVal-st) * (zVal-st);
	 val += 0.036f/r;

	 //Source 5b
	 st = 0.45f*native_sin(0.141f*t-3.7f);
	 ct = 0.49f*native_cos(0.197f*t-1.1f);
	 r = xVal * xVal + (yVal-ct) * (yVal-ct) + (zVal-st) * (zVal-st);
	 val += 0.026f/r;

	 //Source 6b
	 st = 0.4453f*native_sin(0.216341f*t-3.7f);
	 ct = 0.54357f*native_cos(0.234357f*t-4.7f);
	 r = (xVal-ct) * (xVal-ct) + (yVal-st) * (yVal-st) + (zVal-st-ct) * (zVal-st-ct);
	 val += 0.032643f/r;

	 //Source 7b
	 st = 0.3767f*native_sin(0.125673f*t-1.7345f);
	 ct = 0.5156f*native_cos(0.147568f*t-0.7345f);
	 r = (xVal-st) * (xVal-st) + (yVal-ct) * (yVal-ct) + (zVal-st) * (zVal-st);
	 val += 0.07456f/r;

	 //Source 8b
	 st = 0.5735f*native_sin(0.12723f*t-1.7f);
	 ct = 0.61654f*native_cos(0.17734f*t-2.7f);
	 r = (xVal-st) * (xVal-st) + (yVal-ct) * (yVal-ct) + (zVal-st) * (zVal-st);
	 val += 0.036234f/r;
	 
	 //Source 9b
	 st = 0.45f*native_sin(0.141234f*t-3.7435f);
	 ct = 0.49f*native_cos(0.197234f*t-1.2345f);
	 r = xVal * xVal + (yVal-ct) * (yVal-ct) + (zVal-st) * (zVal-st);
	 val += 0.026345f/r;

	 //Source 10b
	 st = 0.43233f*native_sin(0.211f*t-3.7345f);
	 ct = 0.5711f*native_cos(0.237f*t-4.7345f);
	 r = (xVal-ct) * (xVal-ct) + (yVal-st) * (yVal-st) + (zVal-st-ct) * (zVal-st-ct);
	 val += 0.032345f/r;
	 
	 Vals[x+maxX*y+maxXY*z] = val;
      }
]]

local ON  = gl.glEnable
local OFF = gl.glDisable

local ambient_light  = ffi.new( "float[4]", 0.5, 0.5, 0.5, 1.0 )
local diffuse_light  = ffi.new( "float[4]", 0.3, 0.3, 0.3, 1.0 )
local specular_light = ffi.new( "float[4]", 0.1, 0.1, 0.1, 1.0 )
local position       = ffi.new( "float[4]", 1.0, 2.0, 1.0, 1.0 )

local width  = 640
local height = 480

local max_x, max_y, max_z = 65, 65, 65

local edge_coords  = ffi.new( "float[?]",       9 *  max_x    *  max_y    *  max_z    )
local edge_normals = ffi.new( "float[?]",       9 *  max_x    *  max_y    *  max_z    )
local color_data   = ffi.new( "float[?]",   4 * 3 *  max_x    *  max_y    *  max_z    )
local element_data = ffi.new( "int32_t[?]", 5 * 3 * (max_x-1) * (max_y-1) * (max_z-1) )

local bufs         = ffi.new( "GLint[4]" )

local n_elems      = 10
local n_fames      = 0

local function init()
   ON( gl.GL_DEPTH_TEST )
   ON( gl.GL_COLOR_MATERIAL )
   ON( gl.GL_BLEND )
   ON( gl.GL_LIGHTING )
   ON( gl.GL_LIGHT0 )
   gl.glClearColor(    0, 0, 0, 0 )
   gl.glShadeModel(    gl.GL_SMOOTH )
   gl.glDepthFunc(     gl.GL_LEQUAL )
   gl.glColorMaterial( gl.GL_FRONT_AND_BACK,  gl.GL_AMBIENT_AND_DIFFUSE )
   gl.glBlendFunc(     gl.GL_BLEND_SRC_ALPHA, gl.GL_ONE_MINUS_DST_ALPHA )
   gl.glLightfv(       gl.GL_LIGHT0,          gl.GL_AMBIENT,  ambient_light )
   gl.glLightfv(       gl.GL_LIGHT0,          gl.GL_DIFFUSE,  diffuse_light )
   gl.glLightfv(       gl.GL_LIGHT0,          gl.GL_SPECULAR, specular_light )
   gl.glLightfv(       gl.GL_LIGHT0,          gl.GL_POSITION, position )
   gl.glMatrixMode(    gl.GL_PROJECTION )
   gl.glLoadIdentity()
   gl.glOrtho(         -2, 2, -2, 2, -15, 15 )
   gl.glViewport(       0, 0, width, height )
   
   local color_data_length = 4 * 3 * max_x * max_y * max_z
   for i=0, color_data_length - 1, 4 do
      local temp = i / (color_data_length - 1)
      color_data[ i + 1 ] = 3 * temp
      color_data[ i + 2 ] = 0.97
      color_data[ i + 3 ] = 1
   end

   local element_data_length = 5 * 3 * (max_x - 1) * (max_y - 1) * (max_z - 1)
   for i=0, element_data_length - 1 do
      element_data[ i ] = i
   end

   gl.glGenBuffers( 4, bufs )

   gl.glBindBuffer( gl.GL_ARRAY_BUFFER, bufs[0] )
   gl.glBufferData( gl.GL_ARRAY_BUFFER, ffi.sizeof(color_data), color_data, gl.GL_STREAM_DRAW )

   gl.glBindBuffer( gl.GL_ARRAY_BUFFER, bufs[1] )
   gl.glBufferData( gl.GL_ARRAY_BUFFER, ffi.sizeof(edge_coords), edge_coords, gl.GL_STREAM_DRAW )

   gl.glBindBuffer( gl.GL_ARRAY_BUFFER, bufs[2] )
   gl.glBufferData( gl.GL_ARRAY_BUFFER, ffi.sizeof(edge_normals), edge_normals, gl.GL_STREAM_DRAW )

   gl.glBindBuffer( gl.GL_ELEMENT_ARRAY_BUFFER, bufs[3] )
   gl.glBufferData( gl.GL_ELEMENT_ARRAY_BUFFER, ffi.sizeof(element_data), element_data, gl.GL_STREAM_DRAW )

   local devices = {}
   for platform_index, platform in pairs(clGetPlatforms()) do
      local platform_devices = clGetDevices(platform.id)
      for device_index, device in pairs(platform_devices) do
	 devices[ #devices + 1 ] = device
      end
   end

   local device_index = 1
   local context_properties
   if ffi.arch == "OSX" then
      context_properites = ffi.new(
	 "cl_context_properties[7]",
	 cl.CL_CONTEXT_PLATFORM,     ffi.cast( "intptr_t", devices[ device_index ].platform ),
	 cl.CL_GL_CONTEXT_KHR,       ffi.cast( "intptr_t", gl.CGLGetCurrentContext() ),
	 cl.CL_CGL_SHARE_GROUP_KHR,  ffi.cast( "intptr_t", gl.CGLGetShareGroup(gl.CGLGetCurrentContex())),
	 nil )
   elseif ffi.arch == "Windows" then
      context_properties = ffi.new(
	 "cl_context_properites[7]", 
	 cl.CL_CONTEXT_PLATFORM,     ffi.cast( "intptr_t", devices[ device_index ].platform ),
	 cl.CL_GL_CONTEXT_KHR,       ffi.cast( "intptr_t", gl.wglGetCurrentContext() ),
	 cl.CL_WGL_HDC_KHR,          ffi.cast( "intptr_t", gl.wglGetCurrentDC() ),
	 nil )
   else
      error( "No OpenCL <-> OpenGL interop code" )
   end

   local device        = ffi.new( "cl_device_id[1]", devices[ device_index ].id )
   local context       = cl.clCreateContext(      context_properties, 1, device, nil, nil )
   local queue         = cl.clCreateCommandQueue( context, device[0], nil, nil )
   local cgl_colors    = cl.clCreateFromGLBuffer( context, cl.CL_MEM_WRITE_ONLY, bufs[0], nil )
   local cgl_positions = cl.clCreateFromGLBuffer( context, cl.CL_MEM_WRITE_ONLY, bufs[1], nil )
   local cgl_normals   = cl.clCreateFromGLBuffer( context, cl.CL_MEM_WRITE_ONLY, bufs[2], nil )
   local cgl_indices   = cl.clCreateFromGLBuffer( context, cl.CL_MEM_WRITE_ONLY, bufs[3], nil )

            //OpenCLTemplate variables inheritance
            CLCalc.InitCL(Ctx.Handle, CQ.Handle);

            varTempo = new CLCalc.Program.Variable(Tempo);
            varEdgePos = new CLCalc.Program.Variable(CLGLPositions.Handle, EdgeCoords.Length, sizeof(float));
            varEdgeNormals = new CLCalc.Program.Variable(CLGLNormals.Handle, EdgeNormals.Length, sizeof(float));
            varColorIndex = new CLCalc.Program.Variable(CLGLColors.Handle, ColorData.Length, sizeof(float));
            varElemIndex = new CLCalc.Program.Variable(CLGLElemIndex.Handle, ElementData.Length, sizeof(int));

            float[, ,] vals = new float[maxX, maxY, maxZ];
            for (int x = 0; x < maxX; x++)
            {
                float xVal = 2.0f * ((float)x / (float)(maxX - 1) - 0.5f);
                for (int y = 0; y < maxY; y++)
                {
                    float yVal = 2.0f * ((float)y / (float)(maxY - 1) - 0.5f);
                    for (int z = 0; z < maxZ; z++)
                    {
                        float zVal = 2.0f * ((float)z / (float)(maxZ - 1) - 0.5f);
                        float r = xVal * xVal + yVal * yVal + zVal * zVal;

                        vals[x, y, z] = 0.1f / r;

                        r = (xVal - 0.8f) * (xVal - 0.8f) + yVal * yVal + zVal * zVal;
                        vals[x, y, z] += 0.1f / r;

                        r = (yVal + 0.8f) * (yVal + 0.8f) + xVal * xVal + zVal * zVal;
                        vals[x, y, z] += 0.1f / r;
                    }
                }

            }

            //Use OpenGL/OpenCL interop?
            if (USEINTEROP) MC = new OpenCLTemplate.Isosurface.MarchingCubes(vals, varEdgePos, varEdgeNormals, varElemIndex);
            else MC = new OpenCLTemplate.Isosurface.MarchingCubes(vals);

            MC.InitValues = new float[] { -2.0f, -2.0f, -2.0f };
            MC.Increments = new float[] { 4.0f / (float)(maxX-1), 4.0f / (float)(maxY-1), 4.0f / (float)(maxZ-1) };
            
--          MC.ComputeNormals = false;
            
            //OpenCL value updater
            CLCalc.Program.Compile(CLsrc);
            kernelUpdate = new CLCalc.Program.Kernel("UpdateVals");

end

local function draw()
   local tempo = os.clock()
   n_frames = n_frames + 1

   gl.glClear( gl.GL_COLOR_BUFFER_BIT + gl.GL_DEPTH_BUFFER_BIT )
   gl.glMatrixMode( gl.GL_MODELVIEW )
   gl.glLoadIdentity()
   gl.glRotated(        -40, 0.8, 0,   0 )
   gl.glRotated( -tempo * 4,   0, 0, 0.8 )
   
   gl.glBindBuffer( gl.GL_ARRAY_BUFFER, bufs[0] )
   gl.glColorPointer( 4, gl.GL_FLOAT, 0, nil )

   gl.glBindBuffer( gl.GL_ARRAY_BUFFER, bufs[1] )
   gl.glVertexPointer( 3, gl.GL_FLOAT, 0, nil )

   gl.glBindBuffer( gl.GL_ARRAY_BUFFER, bufs[2] )
   gl.glNormalPointer(  gl.GL_FLOAT, 0, nil )

   gl.glBindBuffer( gl.GL_ELEMENT_ARRAY_BUFFER, bufs[3] )

   --GL.Begin(BeginMode.Points);
   --GL.PointSize(3.0f);
   --//GL.Color4(1.0f, 0.0f, 0.0f, 1.0f);
   --//for (int i = 0; i < maxX; i++)
   --//{
   --//    for (int j = 0; j < maxY ; j++)
   --//    {
   --//        for (int k = 0; k < maxZ ; k++)
   --//        {
   --//            GL.Vertex3(2.0f * ((float)i / (float)(maxX - 1) - 0.5f), 2.0f * ((float)j / (float)(maxY - 1) - 0.5f), 2.0f * ((float)k / (float)(maxZ - 1) - 0.5f));
   --//        }
   --//    }
   
   --//}
   --//GL.End();
   
   gl.glEnableClientState( gl.GL_VERTEX_ARRAY )
   gl.glEnableClientState( gl.GL_COLOR_ARRAY )
   gl.glEnableClientState( gl.GL_NORMAL_ARRAY )

   gl.glDrawElements( gl.GL_TRIANLGES, n_elems, gl.GL_UNSIGNED_INT, 0 )

   gl.glDisableClientState( gl.GL_VERTEX_ARRAY )
   gl.glDisableClientState( gl.GL_COLOR_ARRAY )
   gl.glDisableClientState( gl.GL_NORMAL_ARRAY )

   fw.glfwSwapBuffers()


        int maxX, maxY, maxZ;

        ComputeBuffer<float> CLGLPositions;
        ComputeBuffer<float> CLGLNormals;
        ComputeBuffer<float> CLGLColors;
        ComputeBuffer<int> CLGLElemIndex;

        CLCalc.Program.Variable varEdgePos, varEdgeNormals, varElemIndex, varColorIndex;

        Cloo.ComputeContext Ctx;
        CLCalc.Program.Variable varTempo; float[] Tempo = new float[1];
        ComputeCommandQueue CQ;

        //OpenCLTemplate marching cubes algorithm
        OpenCLTemplate.Isosurface.MarchingCubes MC;
        CLCalc.Program.Kernel kernelUpdate;

        System.Diagnostics.Stopwatch fRate = new System.Diagnostics.Stopwatch();
        double nFrames = 0;
        string titulo = "";

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (!initialized) return;

            if (titulo == "") titulo = this.Text;

            if (USEINTEROP)
            {
	       gl.glFinish()

	       local objs = ffi.new( "cl_GLuint[3]", cl_gl_positions, cl_gl_normals, cl_gl_indices )
	       cl.clEnqueueAcquireGLObjects( queue, 3, objs, 0, nil )

                    List<ComputeMemory> c = new List<ComputeMemory>() { CLGLPositions, CLGLNormals, CLGLElemIndex };
                    CQ.AcquireGLObjects(c, null);

                    //Read elapsed time from Stopwatch and write to Device memory
                    Tempo[0] = (float)sw.Elapsed.TotalSeconds;
                    varTempo.WriteToDevice(Tempo);

                    CLCalc.Program.Variable[] args = new CLCalc.Program.Variable[] { varTempo, MC.CLFuncVals };
                    kernelUpdate.Execute(args, new int[] { maxX, maxY, maxZ });

                    MC.CalcIsoSurface(2.5f);

		    cl.clReleaseGLobjects( queue, 
                    //Release objects
                    CQ.ReleaseGLObjects(c, null);
                    CQ.Finish();
            }
            else
            {
                //Read elapsed time from Stopwatch and write to Device memory
                Tempo[0] = (float)sw.Elapsed.TotalSeconds;
                varTempo.WriteToDevice(Tempo);


                CLCalc.Program.Variable[] args = new CLCalc.Program.Variable[] { varTempo, MC.CLFuncVals };
                kernelUpdate.Execute(args, new int[] { maxX, maxY, maxZ });

                MC.CalcIsoSurface(2.5f);


                //Recalculate data
                List<int> ElemArray = new List<int>();
                List<float> Coords = new List<float>();
                List<float> Normals = new List<float>();

                MC.GetEdgeInfo(out Coords, out Normals, out ElemArray);

                //Copy buffer objs
                EdgeCoords = Coords.ToArray();
                EdgeNormals = Normals.ToArray();
                QtdElems = ElemArray.Count;
                
                ElementData = ElemArray.ToArray();

                GL.BindBuffer(BufferTarget.ArrayBuffer, bufs[1]);
                GL.BufferData(BufferTarget.ArrayBuffer, (IntPtr)(EdgeCoords.Length * sizeof(float)), EdgeCoords, BufferUsageHint.StreamDraw);

                GL.BindBuffer(BufferTarget.ArrayBuffer, bufs[2]);
                GL.BufferData(BufferTarget.ArrayBuffer, (IntPtr)(EdgeNormals.Length * sizeof(float)), EdgeNormals, BufferUsageHint.StreamDraw);

                GL.BindBuffer(BufferTarget.ElementArrayBuffer, bufs[3]);
                GL.BufferData(BufferTarget.ElementArrayBuffer, (IntPtr)(ElementData.Length * sizeof(int)), ElementData, BufferUsageHint.StreamDraw);
            }


            //Redraw OpenGL scene
            if (!fRate.IsRunning) fRate.Start();
            this.Text = titulo + " " + Math.Round(nFrames / fRate.Elapsed.TotalSeconds, 2) + " fps";
            glControl1.Invalidate();
        }



