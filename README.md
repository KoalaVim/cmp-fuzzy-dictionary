# cmp-fuzzy-dictionary

`nvim-cmp` source for fuzzy-matched dictionary completions, powered by [fuzzy.nvim](https://github.com/KoalaVim/fuzzy.nvim).

Unlike [cmp-dictionary](https://github.com/uga-rosa/cmp-dictionary) which uses prefix/trie matching, this plugin uses fuzzy matching via `fzf`, `fzy`, or `zf` backends.

## Installation

Depends on [fuzzy.nvim](https://github.com/KoalaVim/fuzzy.nvim) (which depends on `fzf`, `fzy`, or `zf`).

Using [lazy.nvim](https://github.com/folke/lazy.nvim) with `fzy`:

```lua
{ 'romgrk/fzy-lua-native', build = 'make' }
{ 'KoalaVim/fuzzy.nvim', dependencies = { 'romgrk/fzy-lua-native' } }
{ 'KoalaVim/cmp-fuzzy-dictionary', dependencies = { 'KoalaVim/fuzzy.nvim' } }
```

## Setup

```lua
require('cmp').setup({
  sources = cmp.config.sources({
    { name = 'fuzzy_dictionary', keyword_length = 3 },
  }),
})

require('cmp_fuzzy_dictionary').update({
  paths = { '/usr/share/dict/words' },
})
```

**Note:** the source name is `fuzzy_dictionary` in cmp's config.

## Configuration

Configuration is passed via `require('cmp_fuzzy_dictionary').update()`:

### paths (type: table of strings)

Dictionary file paths. Each file should contain one word per line.

_Default:_ `{}`

### max_items (type: int)

Maximum number of fuzzy matches to return.

_Default:_ `15`

### fuzzy_extra_arg

Passed to the fuzzy matching backend. For `fzf`: `case_mode` (0 = smart, 1 = ignore, 2 = respect). For `fzy`: `is_case_sensitive` boolean.

_Default:_ `0`

## Sorting

To sort results by fuzzy match score:

```lua
local compare = require('cmp.config.compare')
cmp.setup({
  sorting = {
    comparators = {
      require('cmp_fuzzy_dictionary.compare'),
      compare.offset,
      compare.exact,
      compare.score,
      -- ...
    },
  },
})
```

## License

MIT
