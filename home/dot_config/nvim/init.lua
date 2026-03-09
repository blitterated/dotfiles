-- Make sure to set up vim options before loading
-- lazy.nvim so that mappings are correct.
require("vim-options")

-- Bootstrap lazy.nvim from ~/.config/nvim/lua/config/lazy.lua.
require("config.lazy")

-- Set colors for line numbers in left gutter.
require("post-theme-linenumber-colors")
