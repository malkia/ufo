local ffi = require( "ffi" )
local lshift, rshift, band = bit.lshift, bit.rshift, bit.and

local map_shift = 10
local map_size = lshift( 1, map_shift )

local hmap = ffi.new( "uint8_t[?]", map_size * map_size )
local lmap = ffi.new( "uint8_t[?]", map_size * map_size )

local drag_yaw
local drag_pitch
local texture_handle


local function calc_light( x1, y1, x2, y2 )
   local max, norm = 0
   for c = 0, 1 do
      for i = y1, y2 do
	 for j = x1, x2 do
	    local h00 = hmap[ band(i * map_size ) j 
	 end
      end
   end
end

    void CalculateLight( int x1, int y1, int x2, int y2 )
    {
       local 
        enum {
            C =  0,
            D = +1,
        };
        int i, j, k, c;
        double max = 0;
        double norm;

        for (c = 0;c < 2;c++)
        {
                for (i = y1;i <= y2;i++)
                {
                        for (j = x1;j <= x2;j++)
                        {
                                int h00 = HMap[((i+C) * MapSize + (j+C)) & (MapSize*MapSize - 1)];
                                int h01 = HMap[((i+C) * MapSize + (j+D)) & (MapSize*MapSize - 1)];
                                int h10 = HMap[((i+D) * MapSize + (j+C)) & (MapSize*MapSize - 1)];
                                int h11 = HMap[((i+D) * MapSize + (j+D)) & (MapSize*MapSize - 1)];
                                int dx = h11 - h00;
                                int dy = h10 - h01;
                                double d = dx * dx + dy * dy;

                                if (c == 0)
                                {
                                        if (max < d)
                                                max = d;
                                }
                                else
                                {
                                        double t = sqrt(d) * norm;
                                        if (t > 255.0)
                                                t = 255.0;
                                        if (t < 0)
                                                t = 0;
                                        LMap[(i * MapSize + j) & (MapSize*MapSize - 1)] = t;
                                }
                        }
                }
                norm = 255.0 / sqrt(max);
        }

        for( k=0; k<=16; k++ )
        for( i=0; i<MapSize*MapSize; i+=MapSize )
        for( j=0; j<MapSize; j++ )
        {
             LMap[i + j] = (LMap[((i + MapSize) & (MapSize * (MapSize-1))) + j] + LMap[i + ((j+1) & (MapSize-1))] +
                            LMap[((i - MapSize) & (MapSize * (MapSize-1))) + j] + LMap[i + ((j-1) & (MapSize-1))]) >> 2;
        }
    }

    void vLine( int x0, int y0, int x1, int y1, float zf, float sf, int Distance )
    {
        float Texel = 1024.0f*65536.0f;
        int State = 0;

        float zsf = getHeight()*(1 - (options.Pitch + dragPitch)) - (zf - Distance) * sf;

        int columnCount = (float)getWidth() / options.ColumnsToSkip;
        int dx = (x1 - x0) / (columnCount + 1);
        int dy = (y1 - y0) / (columnCount + 1);
        float z, ip;
        unsigned l;
        
        sf /= 65536.0f;

        for( int i=0, ip=-options.ColumnsToSkip/2.0f; i<=columnCount; i++, ip += options.ColumnsToSkip, x0 += dx, y0 += dy )
        {
            int b  = (y0 >> 8) & 255;
            int a  = (x0 >> 8) & 255;

            int u0 = x0 >> 16;
            int v0 = y0 >> 16;
            
            int isInside = options.WrapAround || ((unsigned)u0 <= (unsigned)(MapSize - 2) && (unsigned)v0 <= (unsigned)(MapSize - 2));
            
            if( isInside )
            {
                u0 &= (MapSize - 1);
                v0 &= (MapSize - 1);
                
                int u1 = (u0  +  1) & (MapSize - 1);
                int v1 = (v0  +  1) & (MapSize - 1);
                
                v0  <<= MapShift;
                v1  <<= MapShift;
    
                int h0 = HMap[u0+v0];
                int h2 = HMap[u0+v1];
                int h1 = HMap[u1+v0];
                int h3 = HMap[u1+v1];
    
                // Perform bilinear filtering
                h0 = (h0 << 8) + a * (h1 - h0);
                h2 = (h2 << 8) + a * (h3 - h2);
                float h = (h0 << 8) + b * (h2 - h0);
                
                z = h * sf + zsf;
              
                h0 = LMap[u0+v0];
                h2 = LMap[u0+v1];
                h1 = LMap[u1+v0];
                h3 = LMap[u1+v1];
    
                // Perform bilinear filtering
                h0 = ( (h0 << 8) ) + a * (h1 - h0);
                h2 = ( (h2 << 8)  ) + a * (h3 - h2);
                l  = ( (h0<<8) + b * (h2 - h0)) >> 16;
    
                if( !last[i].valid )
                {
                    last[i].x = x0;
                    last[i].y = y0;
                    last[i].z = z;
                    last[i].l = l;
                    last[i].h = h;
                }
                
                if( z > last[i].z )
                {
                    if( State == 0 )
                    {
                        stats.stripCount ++;
                        glBegin( options.WireFrame ? GL_LINE_STRIP : GL_TRIANGLE_STRIP );
                        glTexCoord2f( last[i-1].x / Texel, last[i-1].y / Texel );
                        glColor4ub( last[i-1].l, 255-last[i-1].l, 0, 255-last[i-1].h/2 );
                        glVertex3f(  ip - options.ColumnsToSkip,  last[i-1].z,  -Distance );
    
                        stats.polyCount ++;
                        State = 1;
                    }
                    stats.polyCount += 2;
    
                    glTexCoord2f( (float)x0 / Texel, (float)y0 / Texel );
                    glColor4ub( l, 255-l, 0, 255-h/2 );
                    glVertex3f( ip, z, -Distance);
    
                    glTexCoord2f( last[i].x / Texel, last[i].y / Texel);
                    glColor4ub( last[i].l, 255-l, 0, 255-last[i].h/2 );
                    glVertex3f( ip, last[i].z, -Distance);
    
                    last[i].z = z;
                }
                else if( State == 1 )
                {
                    glTexCoord2f( last[i].x / Texel, last[i].y / Texel );
                    glColor4ub( last[i].l, 255-last[i].l, 0, 255-last[i].h/2 );
                    glVertex3f( ip, last[i].z, -Distance );
                    glEnd();
                    State = 0;
                }
                
                last[i].x = x0;
                last[i].y = y0;
                last[i].l = l;
                last[i].h = h;
                last[i].valid = 1;
            }
            else
            {
                last[i].valid = 0;
            }
        };

        if( State == 1 )
            glEnd();
    }

    MavoxComponent(MavoxOptions**pOptions, MavoxStats **pStats)
    {
        if( pOptions )
           *pOptions = &options;
        
        if( pStats )
           *pStats = &stats;
        
        options.WireFrame     = 0;
        options.FreeFly       = 1;
        options.FieldOfView   = 3.14159256f / 6;
        options.WrapAround    = 0;
        options.ColumnsToSkip = 8.0f;
        options.EyeShot       = 8192; //16384; //4096; //2048;
        options.Xo            = 0;
        options.Yo            = 0;
        options.Zo            = 1000;
        options.Yaw           = 0.8;
        options.ViewScale     = 32768.0f;
        options.Pitch         = 0.7f; //1.5f;
        options.Speed         = 0.0f;
        
        dragYaw        = 0.0f;
        dragPitch      = 0.0f;

        HMap           = (unsigned char*)data_terrain_raw;
        
        image = ImageFileFormat::loadFrom( data_terrain_png, data_terrain_png_size );
        textureHandle = 0;

        LMap = (unsigned char *)malloc( MapSize * MapSize );
        CalculateLight(0,0,MapSize-1,MapSize-1);
    }

    ~MavoxComponent()
    {
        free( LMap );
        delete image;
        deleteAllChildren();
    }

    void resized()
    {
        if(!makeCurrentContextActive())
            return;

        if( textureHandle == 0 )
        {
            glGenTextures(1, &textureHandle);
            glBindTexture( GL_TEXTURE_2D, textureHandle);
            glShadeModel( GL_SMOOTH);
            glEnable( GL_DEPTH_TEST);
            glDepthFunc( GL_LEQUAL );
            glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
            glEnable( GL_TEXTURE_2D );
            glEnable(GL_FOG);
            startTimer( 1000 / 60 );
            
            glBindTexture(GL_TEXTURE_2D,  textureHandle);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            gluBuild2DMipmaps(GL_TEXTURE_2D, 3, image->getWidth(), image->getHeight(), GL_BGR_EXT, GL_UNSIGNED_BYTE, image->getPixelPointer(0,0));
        }

        glViewport(0,0,getWidth(),getHeight());

        glMatrixMode (GL_PROJECTION);
        glLoadIdentity ();
        glOrtho(0,getWidth(), 0,getHeight(), 0,16384);

        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glDisable( GL_LIGHTING );

        float fogColor[4] = {0.5, 0.1, 0.9, 0.5};
        glFogi(   GL_FOG_MODE,  GL_LINEAR );
        glFogfv(  GL_FOG_COLOR, fogColor  );
        glFogf(   GL_FOG_START, options.EyeShot - options.EyeShot / 4 );
        glFogf(   GL_FOG_END,   options.EyeShot );
        glEnable( GL_FOG);
    }

    void renderOpenGL()
    {
        glClearColor( 0.5, 0.1, 0.9, 1.0 );
        glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
        glBindTexture(GL_TEXTURE_2D,  textureHandle);

        float realYaw = options.Yaw + dragYaw;
        
        options.Xo += options.Speed * cosf(realYaw) * 65536.0f;
        options.Yo += options.Speed * sinf(realYaw) * 65536.0f;

        stats.polyCount = 0;

        int u0, v0, u1, v1 ,a , b, h0, h1, h2, h3, h4;
        int x0=options.Xo, y0=options.Yo;

        b  = (y0 >> 8) & 255;
        a  = (x0 >> 8) & 255;

        u0 = (x0 >> 16) & ((1<<MapShift)-1);
        v0 = (y0 >> 16) & ((1<<MapShift)-1);
        u1 = (u0  +  1) & ((1<<MapShift)-1);
        v1 = (v0  +  1) & ((1<<MapShift)-1);

        v0 <<= (MapShift);
        v1 <<= (MapShift);

        h0 = HMap[u0 + v0];
        h2 = HMap[u0 + v1];
        h1 = HMap[u1 + v0];
        h3 = HMap[u1 + v1];

        h0 =  (h0 << 8) + a * (h1 - h0);
        h2 =  (h2 << 8) + a * (h3 - h2);
        h4 = ((h0 << 8) + b * (h2 - h0))>>16;

        if( !options.FreeFly )
            options.Zo = h4;
            
        if( options.Zo <= h4 + 4 )
            options.Zo  = h4 + 4;

        memset( last, 0, sizeof(last));
        float cos_yaw_minus_fieldOfView = cosf(realYaw - options.FieldOfView);
        float sin_yaw_minus_fieldOfView = sinf(realYaw - options.FieldOfView);
        float cos_yaw_plus_fieldOfView  = cosf(realYaw + options.FieldOfView);
        float sin_yaw_plus_fieldOfView  = sinf(realYaw + options.FieldOfView);
        for (int Distance = 1; Distance < options.EyeShot; Distance += 1 + (Distance >> 8))
        {
            float d_s = Distance * options.ViewScale;
            vLine(
                options.Xo + d_s * cos_yaw_minus_fieldOfView,
                options.Yo + d_s * sin_yaw_minus_fieldOfView,
                options.Xo + d_s * cos_yaw_plus_fieldOfView,
                options.Yo + d_s * sin_yaw_plus_fieldOfView,
                options.Zo,
                (float) getHeight() / (float) Distance,
                Distance
            );
        }
    }

    void timerCallback()
    {
        repaint();
    }

    void mouseEnter (const MouseEvent& e)
    {
    }

    void mouseExit (const MouseEvent& e)
    {
    }

    void mouseDown (const MouseEvent& e)
    {
    }

    void mouseUp (const MouseEvent& e)
    {
        options.Yaw   += dragYaw;   dragYaw   = 0;
        options.Pitch += dragPitch; dragPitch = 0;
    }

    void mouseDrag (const MouseEvent& e)
    {
        dragYaw   =  e.getDistanceFromDragStartX()/1024.0f;
        dragPitch = -e.getDistanceFromDragStartY()/1024.0f;
    }

    void mouseMove (const MouseEvent& e)
    {
    }

    void mouseDoubleClick (const MouseEvent& e)
    {
    }

    void mouseWheelMove (const MouseEvent& e, float wheelIncrement)
    {
        if( options.Speed >= 0 && wheelIncrement >= 0 ||
            options.Speed <= 0 && wheelIncrement <= 0 )
            options.Speed += wheelIncrement;
        else
            options.Speed += wheelIncrement*2;
    }

};

Component* MavoxComponentCreate(MavoxOptions**options, MavoxStats**stats)
{
    return new MavoxComponent(options,stats);
}

