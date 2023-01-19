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

This plugin allows you to instantly select or jump to the beginning of an AST node. Add something like this to your `init.lua`.

```lua
vim.keymap.set({'n', 'x', 'o'}, '<space>t', function() require'leap-ast'.leap() end, {})
```

Then, when you're editing a file with a Tree-sitter parser enabled, type `<space>t`. Labels for each AST node that containing the cursor will appear. In normal mode, entering a label will take you to the beginning of the corresponding node. In visual and operator-pending mode, entering a label will select the corresponding node. This is useful for selecting quickly pieces of code based on syntax, which is usually what you want.
