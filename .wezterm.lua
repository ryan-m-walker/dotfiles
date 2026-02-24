local wezterm = require "wezterm"

local config = wezterm.config_builder()

-- window
config.window_background_opacity = 0.90
config.macos_window_background_blur = 50
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE"
config.tab_bar_at_bottom = false

config.window_frame = {
  font = wezterm.font("JetBrainsMono Nerd Font"),
  font_size = 15.0,
}

-- font
config.font = wezterm.font "JetBrainsMono Nerd Font"
config.font_size = 13

config.scrollback_lines = 100000
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 1000

config.window_padding = {
  top = 20,
  bottom = 0,
}

local DARK_THEME = 'Monokai Pro (Gogh)'
local LIGHT_THEME = 'dawnfox'

---@return string
function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

---@param appearance string
---@return string
function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return DARK_THEME
  else
    return LIGHT_THEME
  end
end

config.color_scheme = scheme_for_appearance(get_appearance())
config.underline_thickness = 2

-- config.keys = {
--   {key="Enter", mods="SHIFT", action=wezterm.action{SendString="\x1b\r"}},
-- }

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local term_width = tab.active_pane.width or 80
  local num_tabs = #tabs

  -- Calculate even width per tab, accounting for separators and new tab button
  local available_width = term_width - 4
  local tab_width = math.max(10, math.floor(available_width / num_tabs))

  local title = tab.active_pane.title
  if #title > tab_width - 2 then
    title = wezterm.truncate_right(title, tab_width - 5) .. '...'
  end

  -- Pad to fill width evenly
  local padding_total = tab_width - #title
  local left = math.floor(padding_total / 2)
  local right = padding_total - left

  return string.rep(' ', left) .. title .. string.rep(' ', right)
end)

return config
