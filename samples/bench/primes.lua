
local primes = {}
primes[1] = 2
primes[2] = 3
local nprimes = 2

local function try( n )
    local i = 1
    while true do
        local prime_i = primes[i]
        if prime_i * prime_i >= n then break end
        if ( n % prime_i ) == 0 then
            return;
        end
        i = i + 1
    end
    primes[ nprimes ] = n
    nprimes = nprimes + 1
end

function main()
    for iter=1,100 do

        primes[1] = 2
        primes[2] = 3
        nprimes = 2

        local i = 1
        while nprimes < 25000 do
            local i6 = i * 6
            try( i6 - 1 )
            try( i6 + 1 )
            i = i + 1
        end

        print('--------->', collectgarbage('count'))
    end
end

        collectgarbage()
        print('--------->', collectgarbage('count'))
main()