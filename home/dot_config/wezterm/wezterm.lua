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

--config.color_scheme = 'Purple People Eater (Gogh)'
--config.color_scheme = 'Pixiefloss (Gogh)'
--config.color_scheme = 'Peppermint'
--config.color_scheme = 'PaperColor Dark (base16)'
--config.color_scheme = 'Jellybeans (Gogh)'
--config.color_scheme = 'Abernathy'
--config.color_scheme = 'Astrodark (Gogh)'
--config.color_scheme = 'Atelier Lakeside (base16)'
--config.color_scheme = 'Atelier Seaside (base16)'
--config.color_scheme = 'Aura (Gogh)'
--config.color_scheme = 'Aurora'
--config.color_scheme = 'Japanesque (Gogh)'


--config.color_scheme = 'Jellybeans (Gogh)'
--config.color_scheme = 'JWR dark (terminal.sexy)'
--config.color_scheme = 'Argonaut (Gogh)'
--config.color_scheme = 'Atom (Gogh)'
--config.color_scheme = 'Banana Blueberry'
--config.color_scheme = 'JetBrains Darcula'
--config.color_scheme = 'ayu'
config.color_scheme = 'Ayu Dark (Gogh)'
--config.color_scheme = 'Bamboo Multiplex'

return config
