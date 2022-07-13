# leap-ast.nvim

Jump to, select and operate on AST nodes via the
[Leap](https://github.com/ggandor/leap.nvim) interface with Tree-sitter.

## Requirements

* Neovim >= 0.7.0
* [leap.nvim](https://github.com/ggandor/leap.nvim)
* [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) (This
  dependency is only temporary; it will not be necessary in the future.)

## Installation

Use your preferred plugin manager - no extra steps needed.

## Usage

Just define one mapping, and you're good to go:

```lua
vim.keymap.set({'n', 'x', 'o'}, '<some-key>', function() require'leap-ast'.leap() end, {})
```
