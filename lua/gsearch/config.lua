---@class GsearchConfig
---@field win_size integer Height of the results window.
---@field win_size_zoom integer Height used when the results window is zoomed.
---@field win_pos 'top'|'bottom' Position of the results window.
---@field enable_sort boolean Sort small result sets by file and line number.
---@field sort_lines_threshold integer Maximum number of result lines to sort.
---@field globs string Additional ripgrep arguments, such as `-g '*.lua'`.

local M = {}

---@type GsearchConfig
local defaults = {
  win_size = 15,
  win_size_zoom = 40,
  win_pos = 'bottom',
  enable_sort = true,
  sort_lines_threshold = 100,
  globs = '',
}

---@type GsearchConfig
local options = vim.deepcopy(defaults)

---@type table<string, boolean>
local configured = {}

---@param value unknown
---@param name string
---@return integer
local function positive_integer(value, name)
  if type(value) ~= 'number' or value % 1 ~= 0 or value < 1 then
    error(('gsearch: %s must be a positive integer'):format(name))
  end
  return value
end

---@param value unknown
---@param name string
---@return boolean
local function boolean(value, name)
  if type(value) ~= 'boolean' then
    error(('gsearch: %s must be a boolean'):format(name))
  end
  return value
end

---@param value unknown
---@param name string
---@return string
local function string(value, name)
  if type(value) ~= 'string' then
    error(('gsearch: %s must be a string'):format(name))
  end
  return value
end

---@param value unknown
---@return 'top'|'bottom'
local function window_position(value)
  if value ~= 'top' and value ~= 'bottom' then
    error "gsearch: win_pos must be 'top' or 'bottom'"
  end
  return value
end

---@param user_options? table
function M.setup(user_options)
  user_options = user_options or {}
  if type(user_options) ~= 'table' then
    error 'gsearch: setup options must be a table'
  end

  for key in pairs(user_options) do
    if defaults[key] == nil then
      error(('gsearch: unknown setup option: %s'):format(key))
    end
    configured[key] = true
  end

  local merged = vim.tbl_deep_extend('force', options, user_options)
  options = {
    win_size = positive_integer(merged.win_size, 'win_size'),
    win_size_zoom = positive_integer(merged.win_size_zoom, 'win_size_zoom'),
    win_pos = window_position(merged.win_pos),
    enable_sort = boolean(merged.enable_sort, 'enable_sort'),
    sort_lines_threshold = positive_integer(merged.sort_lines_threshold, 'sort_lines_threshold'),
    globs = string(merged.globs, 'globs'),
  }
end

---@return GsearchConfig
function M.get()
  local config = vim.deepcopy(options)

  -- Keep the original exvim-lite variables usable without requiring setup().
  if not configured.win_size and vim.g.ex_search_winsize ~= nil then
    config.win_size = positive_integer(vim.g.ex_search_winsize, 'g:ex_search_winsize')
  end
  if not configured.win_size_zoom and vim.g.ex_search_winsize_zoom ~= nil then
    config.win_size_zoom =
      positive_integer(vim.g.ex_search_winsize_zoom, 'g:ex_search_winsize_zoom')
  end
  if not configured.win_pos and vim.g.ex_search_winpos ~= nil then
    config.win_pos = window_position(vim.g.ex_search_winpos)
  end
  if not configured.enable_sort and vim.g.ex_search_enable_sort ~= nil then
    config.enable_sort = vim.g.ex_search_enable_sort ~= 0 and vim.g.ex_search_enable_sort ~= false
  end
  if not configured.sort_lines_threshold and vim.g.ex_search_sort_lines_threshold ~= nil then
    config.sort_lines_threshold =
      positive_integer(vim.g.ex_search_sort_lines_threshold, 'g:ex_search_sort_lines_threshold')
  end
  if not configured.globs and vim.g.ex_search_globs ~= nil then
    config.globs = string(vim.g.ex_search_globs, 'g:ex_search_globs')
  end

  return config
end

return M
