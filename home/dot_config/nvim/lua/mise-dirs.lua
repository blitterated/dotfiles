-- nvim/lua/mise-dirs.lua

local M = {}

M.neovim_mise_config_dir = function()
  local nv_cfg_dir = vim.fn.stdpath('config')
  return nv_cfg_dir .. '/mise'
end

M.neovim_mise_tool_install_dir = function()
  local nv_data_dir = vim.fn.stdpath('data')
  return nv_data_dir .. '/mise/installs'
end

M.ensure_neovim_mise_dir = function(dir_path)
  local result = string.format('ensure_neovim_mise_dir(\'%s\')', dir_path)
  return result
end

M.ensure_neovim_mise_config_dir = function()
  local cfg_dir = M.neovim_mise_config_dir()
  local result = M.ensure_neovim_mise_dir(cfg_dir)
  result = 'ensure_neovim_mise_config_dir()'
  return result
end

M.ensure_neovim_mise_tool_install_dir = function()
  local tool_inst_dir = M.neovim_mise_tool_install_dir()
  local result = M.ensure_neovim_mise_dir(tool_inst_dir)
  result = 'ensure_neovim_mise_tool_install_dir()'
  return result
end

return M
