---@class Gsearch
local M = {}

---@class GsearchConfig
---@field win_size? integer Height of the results window. Default: 15.
---@field win_size_zoom? integer Height used when zoomed. Default: 40.
---@field win_pos? 'top'|'bottom' Results window position. Default: `'bottom'`.
---@field enable_sort? boolean Sort small result sets. Default: `true`.
---@field sort_lines_threshold? integer Maximum result lines to sort. Default: 100.
---@field globs? string Extra ripgrep arguments. Default: `''`.

---Configure gsearch. Calling this is optional.
---@param options? GsearchConfig
function M.setup(options)
  require('gsearch.config').setup(options)
end

---Search the current working directory with ripgrep.
---@param pattern string
function M.search(pattern)
  require('gsearch.core').search(pattern)
end

---Search for the word below the cursor.
function M.search_cword()
  M.search(vim.fn.expand '<cword>')
end

---Open the results window without starting a search.
function M.open()
  require('gsearch.core').open()
end

---Toggle the results window.
function M.toggle()
  require('gsearch.core').toggle()
end

---Close the results window.
function M.close()
  require('gsearch.core').close()
end

return M
