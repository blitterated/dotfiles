-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Show line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Disable line wrapping
vim.o.wrap = false

-- Configure Tabs
vim.cmd([[
  set expandtab
  set tabstop=2
  set softtabstop=2
  set shiftwidth=2
]])

-- Show whitespace
vim.cmd("set list listchars=tab:\\ \\ ,trail:·")

-- Turn on cursorline
vim.cmd("set cursorline")

-- Set cursorline number colors in left gutter
vim.api.nvim_set_hl(0, 'LineNr',       { fg='#A1BEEF', bold=true })
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg='#DEEAFF', bold=true })

-- Turn off search highlighting with Enter key
vim.keymap.set("n", "<Enter>", ":nohlsearch<Enter>/<BS>")

-- Format code using LSP
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

-- Prevent gutter from shifting buffer to right with LSP errors and warnings.
vim.o.signcolumn = "yes"

-- Set borders for all floating windows, e.g. hover (Ctrl-w d by default).
vim.o.winborder = 'rounded'
