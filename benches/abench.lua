--[[
	A Bench
	minimal becnhmarking module
]]

local DEFAULT_ITERATIONS = 1000

return function(iterations, no_jit_iterations)
	local bench = {
		iterations = iterations or DEFAULT_ITERATIONS,
		jit_iterations = iterations or DEFAULT_ITERATIONS,
		no_jit_iterations = no_jit_iterations or iterations or DEFAULT_ITERATIONS,
		at = 0,
		times = {},
	}

	function bench:start(name)
		if (not name) then
			at = at + 1
			name = at
		end

		if (not bench.times[name]) then
			bench.times[name] = {}
		end

		bench.times[name][1] = os.clock()
	end

	function bench:stop(name)
		bench.times[name][2] = os.clock()
	end

	function bench:reset()
		self.times = {}
		self.at = 0
	end

	function bench:iterate(func)
		for i = 1, self.iterations do
			func()
		end
	end

	function bench:time(name, func)
		self:start(name)
		self:iterate(func)
		self:stop(name)
	end

	function bench:jitonoff(func)
		collectgarbage()
		collectgarbage()
		jit.flush()
		jit.on()
		self.iterations = self.jit_iterations
		func(true)

		io.write("\n\n")

		collectgarbage()
		collectgarbage()
		jit.flush()
		jit.off()
		self.iterations = self.no_jit_iterations
		func(false)

		io.write("\n\n")
	end

	function bench:results()
		local results_buffer = {
			("JIT %s, %d iterations:"):format(
				(jit.status()) and "on" or "off",
				self.iterations
			),
		}

		local times = {}
		for key, value in pairs(self.times) do
			table.insert(times, {key, value[2] - value[1]})
		end

		self:reset()

		table.sort(times, function(a, b)
			return a[2] < b[2]
		end)

		local best_time = times[1][2]

		for key, value in ipairs(times) do
			table.insert(results_buffer, ("%30s %6gs (%3.fx  best or  %4.f%%)"):format(
				value[1], value[2], value[2] / best_time, 100 * value[2] / best_time
			))
		end

		return table.concat(results_buffer, "\n")
	end

	function bench:doresults()
		print(self:results())
	end

	function bench:describe(str)
		print(str)
		io.write("\n")
	end

	return bench
end