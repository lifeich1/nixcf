---@diagnostic disable-next-line: undefined-global
local wez = wezterm
local mux = wez.mux

wez.on('gui-startup', function(cmd)
  ---@diagnostic disable-next-line: unused-local
  local tab, pane, window = mux.spawn_window(cmd or {})
  local gui_window = window:gui_window();
  gui_window:maximize()
end)

---@diagnostic disable-next-line: unused-function, unused-local
local Wrap = function(cfg)
  cfg.window_background_opacity = 0.85
  cfg.kde_window_background_blur = false
  cfg.font = wez.font 'Fira Code Nerd Font'
  cfg.color_scheme = 'ayu'
  cfg.hide_tab_bar_if_only_one_tab = true
  cfg.tab_bar_at_bottom = true
  return cfg
end
