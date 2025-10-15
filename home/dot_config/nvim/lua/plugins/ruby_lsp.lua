return {
  -- nvim-lspconfig handles LSP client setup
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")

    -- Manually configure ruby_lsp.
    lspconfig.ruby_lsp.setup({
      -- The command to execute the language server.
      -- We use vim.fn.expand to resolve the tilde to the home directory.
      -- This assumes ~/.rbenv/shims is in your PATH and rbenv is initialized.
      --cmd = { vim.fn.expand("~/.rbenv/shims/ruby-lsp") },

      -- The command to execute the language server.
      cmd = { 'ruby-lsp' },

      -- The path to homebrew's ruby installation.
      rubyVersionManager = { identifier = "custom" },
      customRubyCommand = "PATH=$(brew --prefix ruby)/bin:$PATH",

      -- Filetypes for which this LSP should activate.
      filetypes = { "ruby", "eruby" },

      -- Determines the project root directory. Important for LSP context.
      root_dir = lspconfig.util.root_pattern("Gemfile", ".git", ".ruby-version"),

      init_options = { formatter = 'auto' },
    })
  end,
}
