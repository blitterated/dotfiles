
-- "lua_ls" is from the filename: lsp/lua_ls.lua
vim.lsp.enable({ "lua_ls" })



-- Enable autocompletion if the LSP supports it
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_completion) then
      vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy', 'popup' }
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })

      -- Show autocompletion manually with Ctrl-space
      vim.keymap.set('i', '<C-Space>', function()
        vim.lsp.completion.get()
      end)
    end
  end,
})

-- Diagnostics
vim.diagnostic.config({
  --virtual_lines = true -- Show all virtual lines
  virtual_lines = { current_line = true }, -- Only show virtual line for current cursor line
})
