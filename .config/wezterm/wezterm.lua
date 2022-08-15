local wezterm = require 'wezterm';
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
}
