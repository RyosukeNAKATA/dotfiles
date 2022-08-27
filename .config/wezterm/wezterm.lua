local wezterm = require 'wezterm';
return {
  use_ime = true,
  font = wezterm.font("PlemolJP35 Console NF"),
  font_size = 10.0,
  color_scheme = "iceberg-dark",
  window_background_image = "~/Pictures/mamimi.jpg",
  window_background_opacity = 0.7,
  enable_tab_bar = true,
  window_padding = {
    left = 15,
    right = 15,
    top = 5,
    bottom = 5,
  },
  adjust_window_size_when_changing_font_size = true,
}
