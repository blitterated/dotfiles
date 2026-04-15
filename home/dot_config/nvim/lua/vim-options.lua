-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Show line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Disable line wrapping
vim.o.wrap = false

-- Configure Indentation
vim.o.autoindent  = true -- Copy indent from current line
vim.o.expandtab   = true -- Use spaces instead of tabs
vim.o.smartindent = true -- Smart auto-indenting
vim.o.softtabstop = 2    -- Soft tab stop
vim.o.shiftwidth  = 2    -- Indent width
vim.o.tabstop     = 2    -- Tab width

-- Show whitespace
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Turn on cursorline to highlight current line
vim.o.cursorline = true

-- Prevent gutter from shifting buffer to right with LSP errors and warnings.
vim.o.signcolumn = "yes"

-- Set borders for all floating windows, e.g. hover (Ctrl-w d by default).
vim.o.winborder = 'rounded'


-- Key Mappings
-- -----------------------------------------------------------------------------
-- Turn off search highlighting with Enter key
vim.keymap.set("n", "<Enter>", ":nohlsearch<Enter>/<BS>")

-- Format code using LSP
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

-- Toggle relative and absolute line numbers
vim.keymap.set('n', '<leader>rn', ":setlocal relativenumber!<Enter>/<BS>")

-- Toggle visible whitespace characters
--vim.keymap.set('n', '<leader>ws', ':listchars!<Enter>/<BS>', { desc = 'Toggle whitespace' })
--vim.keymap.set('n', '<leader>ws', 'lua vim.opt.list = not vim.opt.list[1]', { desc = 'Toggle whitespace' })

