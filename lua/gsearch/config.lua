local M = {}

---@type GsearchResolvedConfig
local defaults = {
  win_size = 15,
  win_size_zoom = 40,
  win_pos = 'bottom',
  enable_sort = true,
  sort_lines_threshold = 100,
  globs = '',
}

---@type GsearchResolvedConfig
local options = vim.deepcopy(defaults)

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

---@param user_options? GsearchConfig
function M.setup(user_options)
  user_options = user_options or {}
  if type(user_options) ~= 'table' then
    error 'gsearch: setup options must be a table'
  end

  for key in pairs(user_options) do
    if defaults[key] == nil then
      error(('gsearch: unknown setup option: %s'):format(key))
    end
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

---@return GsearchResolvedConfig
function M.get()
  return vim.deepcopy(options)
end

return M
