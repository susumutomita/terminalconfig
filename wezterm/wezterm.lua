local wezterm = require("wezterm")
local config = wezterm.config_builder()

----------------------------------------------------
-- General Settings
----------------------------------------------------

config.automatically_reload_config = true
config.font_size = 16.0
config.font = wezterm.font 'JetBrains Mono'
config.use_ime = true
config.enable_scroll_bar = true
config.window_background_opacity = 0.7
config.macos_window_background_blur = 20

----------------------------------------------------
-- Colors
----------------------------------------------------

-- カラーの定義を分離して整理
local colors = {
  background = "#242e33",  -- 背景色
  foreground = "#cccccc",  -- 前景色
  cursor_bg = "#cccccc",   -- カーソル背景
  cursor_fg = "#242e33",   -- カーソル前景
  ansi = {
    "#242e33",  -- Black (背景色)
    "#a54242",  -- Red
    "#8c9440",  -- Green
    "#de935f",  -- Yellow
    "#81a2be",  -- Blue
    "#85678f",  -- Magenta
    "#5e8d87",  -- Cyan
    "#6c7a80",  -- White
  },
  brights = {
    "#7a7a7a",  -- Bright Black
    "#cc6666",  -- Bright Red
    "#b5bd68",  -- Bright Green
    "#f0c674",  -- Bright Yellow
    "#99dbff",  -- Bright Blue
    "#b294bb",  -- Bright Magenta
    "#8abeb7",  -- Bright Cyan
    "#c5c8c6",  -- Bright White
  }
}

-- 定義した色を設定に適用
config.colors = {
  foreground = colors.foreground,
  background = colors.background,
  cursor_bg = colors.cursor_bg,
  cursor_fg = colors.cursor_fg,
  ansi = colors.ansi,
  brights = colors.brights,
}

config.window_background_gradient = {
  colors = { colors.background },
}

----------------------------------------------------
-- Tabs Settings
----------------------------------------------------

config.show_tabs_in_tab_bar = true

-- タブバーの透明設定
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

-- タブの形状と色のカスタマイズ
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"

  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#1e1e1e"
  end

  local edge_foreground = background
  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

----------------------------------------------------
-- Keybinds
----------------------------------------------------

config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

----------------------------------------------------
-- Final Return
----------------------------------------------------

return config
