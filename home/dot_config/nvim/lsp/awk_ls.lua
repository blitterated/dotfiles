---@brief
---
--- https://github.com/Beaglefoot/awk-language-server/
---
--- `awk-language-server` can be installed via `npm`:
--- ```sh
--- npm install -g awk-language-server
--- ```

local neovim_mise_config_root = vim.fn.stdpath('config') .. '/mise'
local neovim_mise_tool_install_dir = vim.fn.stdpath('data') .. '/mise'

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
  --     awk_ls                  - awk-language-server tool_alias as specified in the Neovim mise.toml.
  --     --                     - Expects command string to follow. a.k.a. --command [-c].
  --     awk-language-server    - awk LSP invocation.
  cmd = { 'mise', 'x', 'awk_ls', '--', 'awk-language-server' },
  cmd_env = {
    --MISE_VERBOSE = "1",
    MISE_GLOBAL_CONFIG_ROOT=neovim_mise_config_root,
    MISE_GLOBAL_CONFIG_FILE=neovim_mise_config_root .. "/config/mise.toml",
    MISE_CEILING_PATHS=neovim_mise_config_root,
    MISE_INSTALLS_DIR=neovim_mise_tool_install_dir
  },
  filetypes = { 'awk' },
}
