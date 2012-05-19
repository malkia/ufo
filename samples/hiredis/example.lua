local ffi = require( "ffi" )
local hr = require( "ffi/hiredis" )

if ffi.os == "Windows" then
   -- klutch - we are using MSOpenTech/bksavecow version of redis (2.4.11)
   ffi.cdef( "int w32initWinSock();" );
   assert( hr.w32initWinSock() == 1 );
end

local c = {}

for i=1, 1 do
   c[i] = ffi.gc( hr.redisConnect( "10.150.9.9", 6380 + i ), hr.redisFree );
   local c = c[i]
--   print('\n CTX',c,'\n ERR',c.err,'\n ERRSTR',ffi.string(c.errstr),
--	 '\n FD',c.fd,'\n FLAGS',c.flags,'\n OBUF',c.obuf,'\n READER',c.reader,'\n' )
   assert( c.err == 0, ffi.string( c.errstr ) )
end

print()

if false then
   local t1 = os.clock()
   local times = 39000
   for i=1, times do
      for x = 1, 1 do
	 local c = c[x]
	 local r = ffi.gc(
	    hr.redisCommand( c, "DEL k"..tostring(i) ),
	    hr.freeReplyObject
	 );
	 --      print(r.str)
	 --      assert( ffi.string( r.str ) == "OK" )
      end
   end
   local t2 = os.clock()
   print( ' DEL', tostring(t2 - t1)..'s / '..tostring(times).. ' = ' .. string.format( "%.7f", 1000*(t2-t1) / times ) .. " ms average del-key" )
end

print(c[1])

local r = {}

for i=1, 1 do
   r[i] = ffi.gc(
      hr.redisCommand( c[i], "KEYS *" ),
      hr.freeReplyObject
   )
   local r = r[i]
   print(r.type, r.integer, r.len, r.elements, r.element)
   --assert(r.type == hr.REDIS_TYPE_ARRAY, "KEYS should return an array")
end

local files = {
}

for i=1, 1 do
   local r = r[i]
   local c = c[i]
   local n = r.elements
   files[i] = {}
   local files = files[i]
   if r.type == hr.REDIS_REPLY_ARRAY then
      for i=0, n-1 do
	 local key = ffi.string( r.element[i].str )
	 local r = ffi.gc(
	    hr.redisCommand( c, "STRLEN " .. key ),
	    hr.freeReplyObject
	 )
	 files[key] = tonumber(r.integer)
      end
   end
end

print( 'files', #files, #files[1] )

local t1 = os.clock()
local times = 0
local bytes = 0
for i=1, 8*0+1 do
   local s = ""
   local max = 1
   local more = max
   for key,len in pairs(files[i]) do
      if false then
	 if more > 0 then
	    s = s .. " " .. key
	    more = more - 1
	 else
	    local r = hr.redisCommand( c[i], "MGET " .. s )
	    --	 for i=0, r.elements-1 do
	    --	    hr.freeReplyObject( r.element[i] )
	    --	 end
	    hr.freeReplyObject( r )
	    --	 print( s )
	    more = max
	    s = ""
	    --	 break
	 end
      else
--	 print(key)
	 local r = hr.redisCommand( c[i], "GET " .. key )
	 hr.freeReplyObject( r )
      end
--      print( 'Read ' .. key .. ' ' .. tostring( len ) .. ' speed ' .. 
--	     tostring(len / (1024*1024*(t2 - t1))) .. ' mb/s' )
      bytes = bytes + len
      times = times + 1
   end
end
local t2 = os.clock()

print( 'Finished retrieving ' .. times .. ' files, ' .. bytes .. ' bytes, speed ' .. tostring(bytes / (1024*1024*(t2 - t1))) .. ' mb/s, total time ' .. (t2 - t1) )
--   print( ffi.string( r.str ) )

-- print( ffi.string(r.str))

while false do
   local t1 = os.clock()
   local times = 39000
   for i = 1, times do
      for x = 1, 8 do
	 local c = c[x]
	 local r = ffi.gc(
	    hr.redisCommand( c, "PING" ),
	    hr.freeReplyObject
	 )
	 assert( ffi.string( r.str ) == "PONG" )
      end
   end
   local t2 = os.clock()
   print( ' PING', tostring(t2 - t1)..'s / '..tostring(times).. ' = ' .. string.format( "%.7f", 1000*(t2-t1) / times ) .. " ms average ping-pong" )

   local t1 = os.clock()
   local times = 39000
   for i=1, times do
      for x = 1, 8 do
	 local c = c[x]
	 local r = ffi.gc(
	    hr.redisCommand( c, "SET k"..tostring(i).." "..tostring(i) ),
	    hr.freeReplyObject
	 );
	 assert( ffi.string( r.str ) == "OK" )
      end
   end
   local t2 = os.clock()
   print( ' SET', tostring(t2 - t1)..'s / '..tostring(times).. ' = ' .. string.format( "%.7f", 1000*(t2-t1) / times ) .. " ms average set-some-key" )
--   print( ffi.string( r.str ) )

   break
end




--[[
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "hiredis.h"

int main(void) {
    unsigned int j;
    redisContext *c;
    redisReply *reply;

    struct timeval timeout = { 1, 500000 }; // 1.5 seconds
    c = redisConnectWithTimeout((char*)"127.0.0.2", 6379, timeout);
    if (c->err) {
        printf("Connection error: %s\n", c->errstr);
        exit(1);
    }

    /* PING server */
    reply = redisCommand(c,"PING");
    printf("PING: %s\n", reply->str);
    freeReplyObject(reply);

    /* Set a key */
    reply = redisCommand(c,"SET %s %s", "foo", "hello world");
    printf("SET: %s\n", reply->str);
    freeReplyObject(reply);

    /* Set a key using binary safe API */
    reply = redisCommand(c,"SET %b %b", "bar", 3, "hello", 5);
    printf("SET (binary API): %s\n", reply->str);
    freeReplyObject(reply);

    /* Try a GET and two INCR */
    reply = redisCommand(c,"GET foo");
    printf("GET foo: %s\n", reply->str);
    freeReplyObject(reply);

    reply = redisCommand(c,"INCR counter");
    printf("INCR counter: %lld\n", reply->integer);
    freeReplyObject(reply);
    /* again ... */
    reply = redisCommand(c,"INCR counter");
    printf("INCR counter: %lld\n", reply->integer);
    freeReplyObject(reply);

    /* Create a list of numbers, from 0 to 9 */
    reply = redisCommand(c,"DEL mylist");
    freeReplyObject(reply);
    for (j = 0; j < 10; j++) {
        char buf[64];

        snprintf(buf,64,"%d",j);
        reply = redisCommand(c,"LPUSH mylist element-%s", buf);
        freeReplyObject(reply);
    }

    /* Let's check what we have inside the list */
    reply = redisCommand(c,"LRANGE mylist 0 -1");
    if (reply->type == REDIS_REPLY_ARRAY) {
        for (j = 0; j < reply->elements; j++) {
            printf("%u) %s\n", j, reply->element[j]->str);
        }
    }
    freeReplyObject(reply);

    return 0;
}
--]]

