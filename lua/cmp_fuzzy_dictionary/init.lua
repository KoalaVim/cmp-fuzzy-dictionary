local backends = require('fuzzy_nvim.backends')
local uv = vim.uv or vim.loop

local defaults = {
	paths = {},
	max_items = 15,
	fuzzy_extra_arg = 0,
	fuzzy_backend = nil,
}

local source = {}

source.new = function(opts)
	local self = setmetatable({}, { __index = source })
	self.words = {}
	self.opts = vim.tbl_deep_extend('keep', opts or {}, defaults)
	self:_load_dicts()
	return self
end

function source:_load_dicts()
	for _, path in ipairs(self.opts.paths) do
		path = vim.fn.expand(path)
		self:_load_dict(path)
	end
end

function source:_load_dict(path)
	local work = uv.new_work(function(dict_path)
		local uv_inner = vim.uv or vim.loop
		local fd = uv_inner.fs_open(dict_path, 'r', 438)
		if not fd then
			return nil
		end
		local stat = assert(uv_inner.fs_fstat(fd))
		local data = assert(uv_inner.fs_read(fd, stat.size, 0))
		assert(uv_inner.fs_close(fd))
		return data
	end, function(data)
		if not data then
			return
		end
		for word in vim.gsplit(data, '\r?\n', { trimempty = true }) do
			self.words[#self.words + 1] = word
		end
	end)
	work:queue(path)
end

function source.get_keyword_pattern()
	return [[\k\+]]
end

function source:complete(params, callback)
	local pattern = params.context.cursor_before_line:sub(params.offset)

	if #self.words == 0 then
		callback({ items = {}, isIncomplete = true })
		return
	end

	vim.schedule(function()
		local completions = {}
		local set = {}
		local matcher = backends.get(self.opts.fuzzy_backend)
		local matches = matcher:filter(pattern, self.words, self.opts.fuzzy_extra_arg)

		for _, result in ipairs(matches) do
			local word, _, score = unpack(result)
			if set[word] == nil then
				set[word] = true
				table.insert(completions, {
					label = word,
					filterText = pattern,
					sortText = word,
					data = { score = score },
					dup = 0,
				})
			end
		end

		table.sort(completions, function(a, b)
			return a.data.score > b.data.score
		end)
		completions = { unpack(completions, 1, self.opts.max_items) }

		callback({
			items = completions,
			isIncomplete = true,
		})
	end)
end

source.update = function(self, opts)
	self.opts = vim.tbl_deep_extend('force', self.opts, opts or {})
	self.words = {}
	self:_load_dicts()
end

return source
