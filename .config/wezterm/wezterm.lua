local wezterm = require 'wezterm';
local act = wezterm.action

return {
  use_ime=true,
  font = wezterm.font("Fira Code"),
  font_size = 15.0,
  color_scheme = "iceberg-dark",
  window_background_opacity = 0.9,
  enable_tab_bar = true,
  window_padding = {
    left = 15,
    right = 15,
    top = 5,
    bottom = 15,
  },
  initial_cols = 190,
  initial_rows = 70,
  adjust_window_size_when_changing_font_size = true,
  native_macos_fullscreen_mode = true,
  keys = {
    -- This will create a new split and run the `top` program inside it
    {
      key = 'd',
      mods = 'CMD|SHIFT',
      action = wezterm.action.SplitPane {
        direction = 'Left',
        size = { Percent = 50 },
      },
    },
    {
      key = 'f',
      mods = 'CMD|SHIFT',
      action = wezterm.action.SplitPane {
        direction = 'Down',
        size = { Percent = 50 },
      },
    },
    {
      key = 'h',
      mods = 'CTRL|SHIFT',
      action = act.ActivatePaneDirection 'Left',
    },
    {
      key = 'l',
      mods = 'CTRL|SHIFT',
      action = act.ActivatePaneDirection 'Right',
    },
    {
      key = 'k',
      mods = 'CTRL|SHIFT',
      action = act.ActivatePaneDirection 'Up',
    },
    {
      key = 'j',
      mods = 'CTRL|SHIFT',
      action = act.ActivatePaneDirection 'Down',
    },
  },
}
