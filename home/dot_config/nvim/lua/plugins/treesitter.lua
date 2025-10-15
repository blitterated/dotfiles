return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup ({
      ensure_installed = {
        "awk",
        "bash",
        "c_sharp",
        "forth",
        "html",
        "java",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "ruby",
        "sql",
        "supercollider",
        "tmux",
        "vim"
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end
}
