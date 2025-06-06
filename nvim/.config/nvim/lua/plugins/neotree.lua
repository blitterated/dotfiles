return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  lazy = false, -- neo-tree will lazily load itself
  config = function()
    vim.keymap.set("n", "<C-n>", ":Neotree toggle left<CR>/<BS>", {})
    vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>/<BS>", {})
  end
}
