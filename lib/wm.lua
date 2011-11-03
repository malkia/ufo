local function handle(type, handlers)
   local handler = handlers[type]
   if handler then
      return true, handler()
   end
end

local function notify(object, event_handler, ...)
   local func = object[ event_handler ]
   if func then
      return true, func(object, ...)
   end
end

local function new()
   return {
      handle = handle,
      notify = notify
   }
end

if ... then
   return new()
end

require = function() new() end

do
   local wm = require( "testing self..." )
end