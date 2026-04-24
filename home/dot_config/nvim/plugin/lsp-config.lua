-- Enable installed LSPs
--   Arguments to `vim.lsp.enable` come from the LSP config filenames
--   found in $XDG_CONFIG_DIR/nivm/lsp/lua_ls.lua.
vim.lsp.enable({ 'lua_ls' })
vim.lsp.enable({ 'bashls' })


-- General LSP Configuration

-- Enable autocompletion if the LSP supports it
-- See: https://github.com/mplusp/minimal-nvim-0.11-lsp-setup/blob/main/lua/config/lsp.lua
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then

      vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy', 'popup' }
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })

      -- Show autocompletion manually with Ctrl-space
      vim.keymap.set('i', '<C-Space>',
        function() vim.lsp.completion.get() end,
        { desc = 'LSP: show autocompletion (manual)' }
      )

      -- Format code using LSP
      vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { desc = 'LSP: format code' })

    end
  end,
})

-- Diagnostics, display virtual lines for Warnings or Errors
-- See: https://github.com/mplusp/minimal-nvim-0.11-lsp-setup/blob/main/lua/config/lsp.lua
vim.diagnostic.config({
  --virtual_lines = true -- Show all virtual lines
  virtual_lines = { current_line = true }, -- Only show virtual line for current cursor line
})
