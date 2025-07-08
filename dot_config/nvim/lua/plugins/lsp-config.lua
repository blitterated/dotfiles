return {
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          ackage_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    }
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "awk_ls",
        "bashls",
        "lua_ls",
        "marksman",
        "pylsp",
        "ruby_lsp",
        "sqls",
        "vimls"
      }
    },
    dependencies = {
        {
          "mason-org/mason.nvim",
          opts = {}
        },
        "neovim/nvim-lspconfig",
    }
  }
}

