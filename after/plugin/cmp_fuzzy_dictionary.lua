if vim.g.loaded_cmp_fuzzy_dictionary then
	return
end
vim.g.loaded_cmp_fuzzy_dictionary = true

local mod = require('cmp_fuzzy_dictionary')
local source = mod.new()
require('cmp').register_source('fuzzy_dictionary', source)

mod.reload = function(opts)
	source:update(opts)
end
