---@brief
---
--- https://github.com/bash-lsp/bash-language-server
---
--- `bash-language-server` can be installed via `npm`:
--- ```sh
--- npm i -g bash-language-server
--- ```
---
--- Language server for bash, written using tree sitter in typescript.

---@type vim.lsp.Config
return {
  -- lua_ls is installed and managed by mise.
  -- Use mise to start the server.
  --
  --   mise x node -- bash-language-server start
  --
  --   Arguments:
  --     mise                   - `mise` invocation.
  --     x                      - `mise` shorthand for the `exec` sub-command.
  --     node                   - bash-language-server is a node package/executable.
  --     --                     - Expects command string to follow. a.k.a. --command [-c].
  --     bash-language-server   - bash LSP invocation.
  --     start                  - The bash-language-server start up command.
  cmd = { 'mise', 'x', 'node', '--', 'bash-language-server', 'start' },

  ---@type lspconfig.settings.bashls
  settings = {
    bashIde = {
      -- Glob pattern for finding and parsing shell script files in the workspace.
      -- Used by the background analysis features across files.

      -- Prevent recursive scanning which will cause issues when opening a file
      -- directly in the home directory (e.g. ~/foo.sh).
      --
      -- Default upstream pattern is "**/*@(.sh|.inc|.bash|.command)".
      globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)',
    },
  },
  filetypes = { 'bash', 'sh' },
  root_markers = { '.git' },
}
