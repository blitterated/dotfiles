vim.pack.add({
  {
    src = 'https://github.com/nvim-telescope/telescope.nvim',
    name = 'Telescope'
  },

  -- dependencies
  'https://github.com/nvim-lua/plenary.nvim',
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
