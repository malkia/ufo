local shell = {}

function shell.exec(cmdline)
   local nout = os.tmpname()
   local nerr = os.tmpname()
   local code = os.execute(
      cmdline .. 
	 ' 1>"' .. nout .. '"' ..
	 ' 2>"' .. nerr .. '"')
   local fout, tout = io.open(nout), {}
   local ferr, terr = io.open(nerr), {}
   for line in fout:lines() do tout[#tout+1] = line end
   for line in ferr:lines() do terr[#terr+1] = line end
   fout:close(); os.remove(nout)
   ferr:close(); os.remove(nerr)
   return code, tout, terr
end

function shell.copy(source, target, bufsize)
   local src = assert(io.open(source, 'rb'))
   local tgt = assert(io.open(target, 'wb'))
   local bufsize = bufsize or 1024 * 1024
   while true do
      local buf = src:read(bufsize)
      tgt:write(buf)
      if #buf ~= bufsize then
	 break
      end
   end
   src:close()
   tgt:close()
end

shell.copy( "/home/malkia/1.bin", "/home/malkia/2.bin" )


local join = table.concat
local code, out, err = shell.exec("ls -lR /etc/")
print(code,join(out,'\n'),join(err, '\n'))
