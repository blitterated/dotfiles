---@brief
---
--- https://github.com/Beaglefoot/awk-language-server/
---
--- `awk-language-server` can be installed via `npm`:
--- ```sh
--- npm install -g awk-language-server
--- ```

---@type vim.lsp.Config
return {
  -- awk_ls is installed by npm and managed by mise.
  -- Use mise to start the server.
  --
  --   mise x node -- awk-language-server
  --
  --   Arguments:
  --     mise                   - `mise` invocation.
  --     x                      - `mise` shorthand for the `exec` sub-command.
  --     node                   - awk-language-server is a node package/executable.
  --     --                     - Expects command string to follow. a.k.a. --command [-c].
  --     awk-language-server    - awk LSP invocation.
  cmd = { 'mise', 'x', 'node', '--', 'awk-language-server' },
  filetypes = { 'awk' },
}
