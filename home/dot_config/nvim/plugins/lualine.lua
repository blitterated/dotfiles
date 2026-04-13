vim.pack.add({
  {
    src = "https://github.com/nvim-lualine/lualine.nvim",
    name = "lualine.nvim"
  },
  -- dependencies
  "https://github.com/nvim-tree/nvim-web-devicons"
})

require("lualine").setup({
  options = {
    theme = "everforest"
  }
})
