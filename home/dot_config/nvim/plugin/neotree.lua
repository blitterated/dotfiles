vim.pack.add({
  {
    src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
    name = "Neo-tree.nvim",
    version = vim.version.range('3')
  },
  -- dependencies
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

vim.keymap.set("n", "<C-n>", ":Neotree toggle left<CR>/<BS>", {})
vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>/<BS>", {})
