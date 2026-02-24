local wezterm = require("wezterm")
local config  = wezterm.config_builder()

config.automatically_reload_config = true

-- UX settings
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.window_close_confirmation = 'NeverPrompt'

-- UI settings
config.initial_cols = 120
config.initial_rows = 32
config.window_decorations = "TITLE | RESIZE"
-- BlinkingBar, BlinkingBlock, BlinkingUnderline, SteadyBar, SteadyBlock, SteadyUnderline
config.default_cursor_style = 'BlinkingBlock'


--config.font = wezterm.font "Hack Nerd Font"
--config.font = wezterm.font "CaskaydiaMono Nerd Font"
--config.font = wezterm.font "FiraCode Nerd Font Mono"
--config.font = wezterm.font "FiraCode Nerd Font"
--config.font = wezterm.font "SauceCodePro Nerd Font"
config.font = wezterm.font "Hasklug Nerd Font"
--config.font = wezterm.font "DroidSansM Nerd Font"
--config.font = wezterm.font "NotoSansM Nerd Font"
--config.font = wezterm.font "CodeNewRoman Nerd Font"
--config.font = wezterm.font "Inconsolata Nerd Font"
--config.font = wezterm.font "InconsolataGo Nerd Font"
--config.font = wezterm.font "Inconsolata LGC Nerd Font"
--config.font = wezterm.font "Iosevka Nerd Font"
--config.font = wezterm.font "IosevkaTerm Nerd Font"
--config.font = wezterm.font "IosevkaTermSlab Nerd Font"
--config.font = wezterm.font "MesloLGL Nerd Font"
--config.font = wezterm.font "MesloLGM Nerd Font"
--config.font = wezterm.font "MesloLGS Nerd Font"
--config.font = wezterm.font "MesloLGLDZ Nerd Font"
--config.font = wezterm.font "MesloLGMDZ Nerd Font"
--config.font = wezterm.font "MesloLGSDZ Nerd Font"
--config.font = wezterm.font "NotoSans Nerd Font"
--config.font = wezterm.font "NotoSerif Nerd Font"
--config.font = wezterm.font "OpenDyslexic Nerd Font"
--config.font = wezterm.font "OpenDyslexicAlt Nerd Font"
--config.font = wezterm.font "OpenDyslexicM Nerd Font"



-- Color Scheme
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
