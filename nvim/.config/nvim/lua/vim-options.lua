-- Show line numbers by default
vim.cmd("set number")

-- Configure Tabs
vim.cmd([[
  set expandtab
  set tabstop=2
  set softtabstop=2
  set shiftwidth=2
]])

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Turn off search highlighting with Enter key
vim.cmd([[
  nmap <Enter> :nohlsearch<Enter>/<BS>
]])
vim.keymap.set("n", "<Enter>", ":nohlsearch<Enter>/<BS>")
