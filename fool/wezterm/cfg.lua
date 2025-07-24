local wezterm = require('wezterm')
local mux = wezterm.mux
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  local gui_window = window:gui_window();
  gui_window:maximize()
end)
local cfg = {}
cfg.window_background_opacity = 0.85
cfg.kde_window_background_blur = false
cfg.font = wezterm.font 'Fira Code Nerd Font'
cfg.color_scheme = 'ayu'
cfg.hide_tab_bar_if_only_one_tab = true
cfg.tab_bar_at_bottom = true
