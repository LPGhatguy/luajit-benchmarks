local bench = require("abench")(
	10000000
)

local data = {1, 2, 3, 4, 5, 6, 7, 8}

local function op(f)
	return f(data)
end

-- baseline: vanilla unpack
local unpack = unpack

-- Neffi #1: Recursion
local function _neffi_unpack(t, i, j)
	if i <= j then
		return t[i], _neffi_unpack(t, i + 1, j)
	end
end

local function neffi_unpack(t, i, j)
	if not i then i = 1 end
	if not j then j = #t end
	if j < i then return end
	return _neffi_unpack(t, i, j)
end

-- LPGhatguy: code generation
local _lpg_cache = {}
local function _lpg_generate(n)
	local str_buffer = {}
	for i = 1, n do
		table.insert(str_buffer, ("arr[%d]"):format(i))
	end
	local str = table.concat(str_buffer, ",")

	return loadstring(("return function(arr) return %s end"):format(str))()
end

local function lpg_unpack(t, n)
	n = n or #t
	if (not _lpg_cache[n]) then
		_lpg_cache[n] = _lpg_generate(n)
	end
	
	return _lpg_cache[n](t)
end

-- Neffi #2: CPS + tailcall
local function _neffi2_unpack(t, i, j, ...)
	if j >= i then
		return _neffi2_unpack(t, i, j - 1, t[j], ...)
	end
	return ...
end

function neffi2_unpack(t, i, j)
	if not i then i = 1 end
	if not j then j = #t end
	if j < i then return end
	return _neffi2_unpack(t, i, j)
end

bench:describe([[
Unpack comparison

Compares vanilla NYI unpack with a couple other implementations:
- Neffi #1 (impure recursion)
- LPGhatguy (code generation)
- Neffi #2 (CPS + tailcall)
]])
bench:jitonoff(function()
	bench:time("Baseline", function()
		op(unpack)
	end)

	bench:time("Neffi #1", function()
		op(neffi_unpack)
	end)

	bench:time("LPGhatguy", function()
		op(lpg_unpack)
	end)

	bench:time("Neffi #2", function()
		op(neffi2_unpack)
	end)

	bench:doresults()
end)