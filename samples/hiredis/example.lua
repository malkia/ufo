local ffi = require( "ffi" )
local hr = require( "ffi/hiredis" )

if ffi.os == "Windows" then
   -- klutch - we are using MSOpenTech/bksavecow version of redis (2.4.11)
   ffi.cdef( "int w32initWinSock();" );
   assert( hr.w32initWinSock() == 1 );
end

local c = {}

for i=1, 8 do
   c[i] = ffi.gc( hr.redisConnect( "taAssetCache", 6380 + i ), hr.redisFree );
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
      for x = 1, 8 do
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

for i=1, 8 do
   r[i] = ffi.gc(
      hr.redisCommand( c[i], "KEYS *" ),
      hr.freeReplyObject
   )
   local r = r[i]
   print(r.type, r.integer, r.len, r.elements, r.element)
   --assert(r.type == hr.REDIS_TYPE_ARRAY, "KEYS should return an array")
end

local t1 = os.clock()
local times = 0
local bytes = 0
for i=1, 8 do
   print(i)
   local r = r[i]
   local c = c[i]
   local n = r.elements
   if r.type == hr.REDIS_REPLY_ARRAY then
      for i=0, n-1 do
	 local key = ffi.string( r.element[i].str )
	 local r = ffi.gc(
	    hr.redisCommand( c, "STRLEN " .. key ),
	    hr.freeReplyObject
	 )
	 local len = tonumber(r.integer)
	 local t1 = os.clock()
	 local r = ffi.gc(
	    hr.redisCommand( c, "GET " .. key ),
	    hr.freeReplyObject
	 )
	 local t2 = os.clock()
	 print( 'Read ' .. tostring(i+1) .. '/' .. tostring(n) .. ' ' ..
		key .. ' ' .. tostring( len ) .. ' speed ' .. tostring(len / (1024*1024*(t2 - t1))) .. ' mb/s' )
	 times = times + 1
	 bytes = bytes + len
      end
   end
end
local t2 = os.clock()

print( 'Finished retrieving ' .. times .. ' speed ' .. tostring(bytes / (1024*1024*(t2 - t1))) .. ' mb/s ' .. ' total time ' .. (t2 - t1) )
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

