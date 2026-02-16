local wezterm = require("wezterm")
local config  = wezterm.config_builder()

config.automatically_reload_config = true
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.window_close_confirmation = 'NeverPrompt'

--config.window_decorations = "RESIZE"
config.window_decorations = "TITLE | RESIZE"

-- BlinkingBar, BlinkingBlock, BlinkingUnderline, SteadyBar, SteadyBlock, SteadyUnderline
config.default_cursor_style = 'BlinkingBlock'

return config
