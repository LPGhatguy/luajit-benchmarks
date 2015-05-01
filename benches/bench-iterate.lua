local bench = require("abench")(
	10000000
)

local function nop(n)
	return n
end

local function dov(...)
	for i = 1, select("#", ...) do
		nop(select(i, ...))
	end
end

local function dot(...)
	local t = {...}
	for i, v in ipairs(t) do
		nop(v)
	end
end

bench:describe([[
Iteration benchmark

Compares iteration speeds of iteration methods:
- varargs (using select)
- sequences (using ipairs)
]])
bench:jitonoff(function()
	bench:time("Varargs (...)", function()
		dov(1, 2, 3)
	end)

	bench:time("Sequence {...}", function()
		dot(1, 2, 3)
	end)

	bench:doresults()
end)