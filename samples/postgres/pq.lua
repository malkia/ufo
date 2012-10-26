local ffi = require( "ffi" )
local pq = require( "ffi/pq" )

-- http://www.postgresql.org/docs/9.2/static/libpq-connect.html#LIBPQ-PARAMKEYWORDS

print()

local function print_defaults()
   local defaults = pq.PQconndefaults();
   for _,v in pairs{ "keyword", "envvar", "compiled", "val", "label", "dispchar", "dispsize" } do
      local n = defaults[v]
      if type(n) ~= "number" then
	 n = ffi.string(n)
      end
      print('DEFAULTS', v, n)
   end
end
print_defaults();

local conn = ffi.gc(
   pq.PQconnectdb(
      "host=localhost " ..
	 "application_name=from_luajit " ..
	 "port=5432 " ..
	 "dbname=t7 " .. 
	 "user=postgres " ),
   pq.PQfinish)

print('conn', conn)
print('db',   ffi.string(pq.PQdb(conn)))
print('user', ffi.string(pq.PQuser(conn)))
print('host', ffi.string(pq.PQhost(conn)))
print('port', ffi.string(pq.PQport(conn)))
print('tty',  ffi.string(pq.PQtty(conn)))
print('opts', ffi.string(pq.PQoptions(conn)))
print('conn_s', pq.PQstatus(conn))
print('trans_s', pq.PQtransactionStatus(conn))

local function print_parameters()
   for _,v in pairs{  "server_version", "server_encoding", "client_encoding", "application_name",
		      "is_superuser", "session_authorization", "DateStyle", "IntervalStyle", 
		      "TimeZone", "integer_datetimes", "standard_conforming_strings" } 
   do
      print('param', v, ffi.string(pq.PQparameterStatus(conn, v)))
   end
end
print_parameters()

print('protocol version', pq.PQprotocolVersion(conn))
print('server version', pq.PQserverVersion(conn))
print('socket', pq.PQsocket(conn))
print('backend pid', pq.PQbackendPID(conn))
print('needs password?', pq.PQconnectionNeedsPassword(conn))

local res = ffi.gc(pq.PQexec( conn, "SELECT * FROM gdt._entity;"), pq.PQclear)
print(res)
print('result status', pq.PQresultStatus(res), pq.PGRES_TUPLES_OK)
print('result status', ffi.string(pq.PQresStatus(pq.PQresultStatus(res))))
print('error status', ffi.string(pq.PQresultErrorMessage(res)))
local ntuples, nfields = pq.PQntuples(res), pq.PQnfields(res)
print('ntuples', ntuples)
print('nfields', nfields)
local columns = {}
local coloids = {}
local coltabs = {}
local colfmts = {}
local colftyp = {}
local colfmod = {}
for i=0, nfields-1 do
   local name = ffi.string(pq.PQfname(res, i))
   columns[#columns+1] = name
   assert(i==pq.PQfnumber(res,name)) 
   coloids[name] = pq.PQftable(res,i)
   coltabs[name] = pq.PQftablecol(res,i)
   colfmts[name] = pq.PQfformat(res,i)
   colftyp[name] = pq.PQftype(res,i)
   colfmod[name] = pq.PQfmod(res,i)
end
print('columns',table.concat(columns,', '))
for k,v in pairs(coloids) do print('oid',k,v) end
for k,v in pairs(coltabs) do print('tabind',k,v) end
for k,v in pairs(colfmts) do print('format',k,v) end
for k,v in pairs(colftyp) do print('type',k,v) end
for k,v in pairs(colfmod) do print('fmod',k,v) end
print('binaryTyples?',pq.PQbinaryTuples(res))
print('isnonblocking?',pq.PQisnonblocking(conn))

for i=0,ntuples-1 do
   local s = {}
   for j=0,nfields-1 do
      s[#s+1] = ffi.string(pq.PQgetvalue(res,i,j))
   end
   print(table.concat(s,', '))
end

