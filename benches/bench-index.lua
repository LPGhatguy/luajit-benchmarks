local bench = require("abench")(
	1000000000,
	10000000
)

-- Pure data
local data = {
	a = 1, b = 2, c = 3
}

-- Functional index interface
local func_i = newproxy(true)
getmetatable(func_i).__index = function(self, key)
	return data[key]
end

-- Redirect index interface
local func_t = newproxy(true)
getmetatable(func_t).__index = data

-- NOP
local function nop(a, b, c)
	return a, b, c
end

bench:describe([[
Indexing benchmark

Compares indexing using pure access, table value __index (redirect) and
function value __index.
]])
bench:jitonoff(function()
	bench:time("baseline", function()
		nop(data.a, data.b, data.c)
	end)

	bench:time("redirect interface", function()
		nop(func_t.a, func_t.b, func_t.c)
	end)

	bench:time("function interface", function()
		nop(func_i.a, func_i.b, func_i.c)
	end)

	bench:doresults()
end)