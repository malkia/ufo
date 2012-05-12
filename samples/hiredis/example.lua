local ffi = require( "ffi" )
local hr = require( "ffi/hiredis" )

if ffi.os == "Windows" then
   -- klutch
   ffi.cdef( "int w32initWinSock();" );
   assert( hr.w32initWinSock() == 1 );
end

local c = ffi.gc( hr.redisConnect( "taassetcache", 6379 ), hr.redisFree );
print('\n CTX',c,'\n ERR',c.err,'\n ERRSTR',ffi.string(c.errstr),
      '\n FD',c.fd,'\n FLAGS',c.flags,'\n OBUF',c.obuf,'\n READER',c.reader,'\n' )
assert( c.err == 0, ffi.string( c.errstr ) )

while true do
   local t1 = os.clock()
   local times = 39000
   for i=1, times do
      local r = ffi.gc( hr.redisCommand( c, "PING" ), hr.freeReplyObject );
      assert( r.err == 0 )
      assert( r.err==0 and ffi.string( r.str ) == "PONG" )
   end
   local t2 = os.clock()
   print( ' PING', tostring(t2 - t1)..'s / '..tostring(times).. ' = ' .. string.format( "%.7f", 1000*(t2-t1) / times ) .. " ms average ping-pong time with ffi/gc/etc." )

   if true then 
      break
   end

   local t1 = os.clock()
   local times = 39000
   for i=1, times do
      local r = ffi.gc( hr.redisCommand( c, "SET k"..tostring(i).." "..tostring(i) ), hr.freeReplyObject );
      assert( ffi.string( r.str ) == "OK" )
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

