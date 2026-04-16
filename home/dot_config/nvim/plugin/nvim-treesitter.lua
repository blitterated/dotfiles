vim.pack.add({{
  src = "https://github.com/nvim-treesitter/nvim-treesitter/",
  name = "nvim-treesitter",
  version = "main",
}})

local ts_config = require("nvim-treesitter")

ts_config.setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
})

-- Install parsers and queries.
-- It's a no-op if they're already installed.
ts_config.install({
  --"awk",
  "bash",
  --"c",
  "c_sharp",
  --"forth",
  --"fsharp",
  --"go",
  "html",
  --"java",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  --"powershell",
  "python",
  "ruby",
  "sql",
  --"supercollider",
  --"swift",
  --"tmux",
  --"typescript",
  "vim"
})


-- Filetype detection is enabled by default. Sinking this event use to require running ":filetype on."
--   :h nvim-defaults 
vim.api.nvim_create_autocmd('FileType', {
  callback = function()

    -- Enable treesitter highlighting and disable regex syntax
    --   See: https://www.qu8n.com/posts/treesitter-migration-guide-for-nvim-0-12
    pcall(vim.treesitter.start)

    -- Enable treesitter-based indentation
    --   See: https://www.qu8n.com/posts/treesitter-migration-guide-for-nvim-0-12
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

    -- Enable Treesitter-based folding
    --vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    --vim.wo[0][0].foldmethod = 'expr'

  end,
})


-- Update installed parsers whenever Treesitter itself is updated
-- See: https://github.com/mplusp/nvim-0.12-vim-pack-intro/blob/main/lua/plugins/nvim-treesitter.lua
vim.api.nvim_create_autocmd('PackChanged', {
  desc = 'Handle nvim-treesitter updates',
  group = vim.api.nvim_create_augroup('nvim-treesitter-pack-changed-update-handler', { clear = true }),

  callback = function(event)
    if event.data.kind == 'update' and event.data.spec.name == 'nvim-treesitter' then

      vim.notify('nvim-treesitter updated, running TSUpdate...', vim.log.levels.INFO)

      ---@diagnostic disable-next-line: param-type-mismatch
      local ok = pcall(vim.cmd, 'TSUpdate')

      if ok then
        vim.notify('TSUpdate completed successfully!', vim.log.levels.INFO)
      else
        vim.notify('TSUpdate command not available yet, skipping', vim.log.levels.WARN)
      end

    end
  end,
})
