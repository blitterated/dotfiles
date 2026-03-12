-- Set line number colors in left gutter

-- Relative line numbers above the cursor line
vim.api.nvim_set_hl(0, 'LineNrAbove',  { fg='#FFFF00', bold=true })

-- Absolute line numbers above and below cursor line
vim.api.nvim_set_hl(0, 'LineNr',       { fg='#AAAAFF', bold=true })

-- Absolute line number on the cursor line
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg='#FFAAAA', bold=true })

-- Relative line numbers below the cursor line
vim.api.nvim_set_hl(0, 'LineNrBelow',  { fg='#AAFFFF', bold=true })
