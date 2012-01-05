require( "bit" )
require( "math" )
local band, shl, shr, min = bit.band, bit.lshift, bit.rshift, math.min

local ffi = require( "ffi" )
local lzf = ffi.load( "lzf" )
local winmm = ffi.load( "WINMM" )
ffi.cdef[[
unsigned lzf_compress( const void *const in, unsigned in_len, void *out, unsigned out_len);
unsigned lzf_decompress( const void *const in, unsigned in_len, void *out, unsigned out_len);
unsigned timeGetTime();
]]

local function lzf_compress_ffi( inp, out, htab )
	local MAX_LIT = 32
	local MAX_OFF = 8192
	local MAX_REF = 264
	local inp_size = ffi.sizeof( inp )

	print( "inp_size = ", inp_size )

	local out_size = inp_size * 2
	if out == nil then
	   out = ffi.new( "uint8_t[?]", out_size )
	else
	   out_size = ffi.sizeof(out)
	end

	if htab == nil then
	   htab = ffi.new( "uint32_t[?]", 65536 )
	else
	   assert( ffi.sizeof(htab) == 65536 * 4 )
	   ffi.fill(htab, ffi.sizeof(htab))
	end

	local ref, lit, ip, op = 0, 0, 0, 1
	local hval = shl(inp[ip], 8) + inp[ip + 1]

	while ip + 1 <= inp_size
	do
		if math.mod(ip,256)==0 then
			print(ip)
		end

		hval = shl(hval, 8) + inp[ip + 2]
		local idx = band(shr(hval, 8) - hval, 0xFFFF)
		ref, htab[ idx ] = htab[ idx ], ip
		local off = ip - ref - 1

		if  true
		and ref < ip
		and off < MAX_OFF
		and ip + 4 < inp_size
		and ref > 0
		and inp[ref + 0] == inp[ip + 0]
		and inp[ref + 1] == inp[ip + 1]
		and inp[ref + 2] == inp[ip + 2]
		then
			local len = 2
			local maxlen = inp_size - ip - len
			maxlen = min(maxlen, MAX_REF)
			out[ op - lit - 1 ] = lit - 1
			if lit == 0 then
				op = op - 1
			end
			-- If we guarantee that out_size would be enough we don't need that one
			if op + 4 >= out_size then
				return 0
			end
			while true do
				if maxlen > 16 then
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end

					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end

					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end

					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
					len = len + 1; if inp[ref + len] ~= inp[ip + len] then break end
				end
				repeat
					len = len + 1
				until (len < maxlen) and (inp[ref + len] == inp[ip + len])
				break;
			end
			len = len - 2
			ip = ip + 1
			if len < 7 then
				out[op] = shr(off, 8) + shl(len, 5)
				op = op + 1
			else
				out[op + 0] = shr(off, 8) + shl(7, 5)
				out[op + 1] = len - 7
				op = op + 2
			end
			out[ op ] = off
			lit = 0
			op = op + 2
			ip = ip + len + 1
			if ip + 2 >= inp_size then
				break
			end
		        ip = ip - 1
			hval = shl(inp[ip + 0], 16) + shl(inp[ip + 1], 8) + inp[ ip + 2 ]
			htab[band(shr(hval, 8) - hval, 0xFFFF)] = ip
			ip = ip + 1
		else
			if op >= out_size then
				return nil
			end
			lit = lit + 1
			out[ op ] = inp[ ip ]
			op = op + 1
			ip = ip + 1
			if lit == MAX_LIT then
				out[ op - lit - 1 ] = lit - 1
				lit = 0
				op = op + 1
			end
		end
	end

	if op + 3 > out_size then
		return 0
	end

	while ip < inp_size do
		lit = lit + 1
		out[ op ] = out[ ip ]
		op = op + 1
		ip = ip + 1
		if lit == MAX_LIT then
			out[op - lit - 1] = lit - 1
			lit = 0
			op = op + 1
		end
	end

	out[ op - lit - 1] = lit - 1
	if lit == 0 then
		op = op - 1
	end

	return out, op
end

local function load_file(n)
   return io.open(n,"rb"):read("*all")
end

local function save_file(n,s)
   return io.open(n,"wb"):write(s)
end

-- Load the file in lua string
local lua_src_blob = load_file("1.DB")

-- Copy the loaded file from the lua string to a FFI array of uint8_t
local ffi_src_blob = ffi.new( "uint8_t[?]", #lua_src_blob, lua_src_blob )

-- Allocate also FFI space for compression, twice the size of the source data (Probably too much)
local ffi_dst_blob = ffi.new( "uint8_t[?]", ffi.sizeof(ffi_src_blob) * 2 )

local t1 = winmm.timeGetTime()
local comp_size = lzf.lzf_compress( ffi_src_blob, ffi.sizeof(ffi_src_blob), ffi_dst_blob, ffi.sizeof(ffi_dst_blob) )
local t2 = winmm.timeGetTime() - t1
print( "time = ".. tostring(t2).. " ms, comp_size = "..tostring( comp_size) )

--local t1 = os.clock()
--local comp, size = lzf_compress_ffi( binary )
--local t2 = os.clock()
--print( "time = ", t2 - t1 )

--print(ffi.sizeof(binary))
--print(size)
save_file('1.cdb',ffi.string(ffi_dst_blob, comp_size))
