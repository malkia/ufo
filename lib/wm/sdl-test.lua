local wm = require( "lib/wm/sdl" )

while wm:update() do
   if wm.kb == 27 then 
      wm:exit()
   end
end


