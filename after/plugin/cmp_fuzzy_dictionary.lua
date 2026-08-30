if vim.g.loaded_cmp_fuzzy_dictionary then
	return
end
vim.g.loaded_cmp_fuzzy_dictionary = true

local source = require('cmp_fuzzy_dictionary').new()
require('cmp').register_source('fuzzy_dictionary', source)

require('cmp_fuzzy_dictionary').update = function(opts)
	source:update(opts)
end
