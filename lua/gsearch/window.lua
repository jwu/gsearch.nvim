local M = {}

---@param window integer|nil
---@return boolean
local function is_edit_window(window)
  if type(window) ~= 'number' or not vim.api.nvim_win_is_valid(window) then
    return false
  end

  local buffer = vim.api.nvim_win_get_buf(window)
  return vim.api.nvim_get_option_value('buftype', { buf = buffer }) == ''
end

---@return integer|nil
function M.last_edit_window()
  local loaded, win_buf_op = pcall(require, 'win-buf-op')
  if loaded and type(win_buf_op) == 'table' and type(win_buf_op.last_edit_window) == 'function' then
    local called, window = pcall(win_buf_op.last_edit_window)
    if called and is_edit_window(window) then
      return window
    end
  end

  for _, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if is_edit_window(window) then
      return window
    end
  end
end

return M
