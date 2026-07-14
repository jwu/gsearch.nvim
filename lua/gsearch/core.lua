local api = vim.api
local results = require 'gsearch.results'

local M = {}

---@type integer|nil
local result_buffer = nil
---@type integer|nil
local result_window = nil
---@type integer|nil
local edit_window = nil
local help_open = false
local zoomed = false
local help_lines = { '" Press <F1> for help', '' }
local confirmed_line = nil
local result_namespace = api.nvim_create_namespace 'gsearch-results'
local target_namespace = api.nvim_create_namespace 'gsearch-target'

local full_help = {
  '" Press <F1> for help',
  '',
  '" <F1>: Toggle Help',
  '" <ESC>: Close Window',
  '" <Space>: Zoom in/out window',
  '" <Enter>: Go to the search result',
  '" <2-LeftMouse>: Go to the search result',
  '" <Shift-Enter>: Go to the search result in split window',
  '" <Shift-2-LeftMouse>: Go to the search result in split window',
  '" <leader>r: Filter out search result',
  '" <leader>fr: Filter out search result (files only)',
  '" <leader>d: Reverse filter out search result',
  '" <leader>fd: Reverse filter out search result (files only)',
}

local short_help = { full_help[1], full_help[2] }

---@return boolean
local function result_buffer_valid()
  return result_buffer ~= nil and api.nvim_buf_is_valid(result_buffer)
end

---@return boolean
local function result_window_valid()
  return result_window ~= nil
    and api.nvim_win_is_valid(result_window)
    and api.nvim_win_get_buf(result_window) == result_buffer
end

local function clear_target()
  for _, buffer in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_valid(buffer) then
      api.nvim_buf_clear_namespace(buffer, target_namespace, 0, -1)
    end
  end
end

---@param buffer integer
---@param namespace integer
---@param group string
---@param row integer
---@param start_column integer
---@param end_column integer
local function add_highlight(buffer, namespace, group, row, start_column, end_column)
  if end_column == -1 then
    local line = api.nvim_buf_get_lines(buffer, row, row + 1, false)[1] or ''
    end_column = #line
  end

  api.nvim_buf_set_extmark(buffer, namespace, row, start_column, {
    end_col = end_column,
    hl_group = group,
  })
end

---@param buffer integer
local function highlight(buffer)
  api.nvim_buf_clear_namespace(buffer, result_namespace, 0, -1)
  local lines = api.nvim_buf_get_lines(buffer, 0, -1, false)

  for index, line in ipairs(lines) do
    local row = index - 1
    if line:sub(1, 1) == '"' then
      add_highlight(buffer, result_namespace, 'Comment', row, 0, -1)
    elseif line:match '^%-%-%-%-%-%-%-%-%-%-' then
      add_highlight(buffer, result_namespace, 'Title', row, 0, -1)
    else
      local filename, line_number = results.parse(line)
      if filename then
        add_highlight(buffer, result_namespace, 'Directory', row, 0, #filename)
        local number_start = #filename + 1
        add_highlight(
          buffer,
          result_namespace,
          'Number',
          row,
          number_start,
          number_start + #tostring(line_number)
        )
      end
    end
  end

  if confirmed_line then
    add_highlight(buffer, result_namespace, 'GsearchConfirm', confirmed_line - 1, 0, -1)
  end
end

local function render(lines)
  local buffer = assert(result_buffer)
  api.nvim_set_option_value('modifiable', true, { buf = buffer })
  api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  api.nvim_set_option_value('modifiable', false, { buf = buffer })
  highlight(buffer)
end

---@return integer
local function get_edit_window()
  if edit_window and api.nvim_win_is_valid(edit_window) and edit_window ~= result_window then
    return edit_window
  end

  for _, window in ipairs(api.nvim_tabpage_list_wins(0)) do
    if window ~= result_window then
      edit_window = window
      return window
    end
  end

  vim.cmd 'rightbelow vsplit'
  edit_window = api.nvim_get_current_win()
  return edit_window
end

local function focus_results()
  if result_window_valid() then
    api.nvim_set_current_win(assert(result_window))
  end
end

local function reset_on_close()
  result_window = nil
  help_open = false
  zoomed = false
  clear_target()
end

function M.close()
  if result_window_valid() then
    api.nvim_set_current_win(assert(result_window))
    vim.cmd 'close'
  end
end

local function add_buffer_mappings(buffer)
  local function map(keys, callback)
    vim.keymap.set('n', keys, callback, { buffer = buffer, silent = true })
  end

  map('<F1>', M.toggle_help)
  map('<Esc>', M.close)
  map('<Space>', M.toggle_zoom)
  map('<CR>', function()
    M.select()
  end)
  map('<2-LeftMouse>', function()
    M.select()
  end)
  map('<S-CR>', function()
    M.select(true)
  end)
  map('<S-2-LeftMouse>', function()
    M.select(true)
  end)
  map('<leader>r', function()
    M.filter(vim.fn.getreg '/', 'pattern', false)
  end)
  map('<leader>fr', function()
    M.filter(vim.fn.getreg '/', 'file', false)
  end)
  map('<leader>d', function()
    M.filter(vim.fn.getreg '/', 'pattern', true)
  end)
  map('<leader>fd', function()
    M.filter(vim.fn.getreg '/', 'file', true)
  end)
end

local function initialize_buffer(buffer)
  api.nvim_buf_set_name(buffer, '[GSearch Results]')
  api.nvim_set_option_value('buftype', 'nofile', { buf = buffer })
  api.nvim_set_option_value('bufhidden', 'hide', { buf = buffer })
  api.nvim_set_option_value('swapfile', false, { buf = buffer })
  api.nvim_set_option_value('buflisted', false, { buf = buffer })
  api.nvim_set_option_value('modifiable', false, { buf = buffer })
  add_buffer_mappings(buffer)

  api.nvim_buf_create_user_command(buffer, 'R', function(command)
    M.filter(command.args, 'pattern', false)
  end, { nargs = 1 })
  api.nvim_buf_create_user_command(buffer, 'FR', function(command)
    M.filter(command.args, 'file', false)
  end, { nargs = 1 })
  api.nvim_buf_create_user_command(buffer, 'D', function(command)
    M.filter(command.args, 'pattern', true)
  end, { nargs = 1 })
  api.nvim_buf_create_user_command(buffer, 'FD', function(command)
    M.filter(command.args, 'file', true)
  end, { nargs = 1 })

  api.nvim_create_autocmd('BufWinLeave', {
    buffer = buffer,
    callback = reset_on_close,
  })
end

---@param config GsearchResolvedConfig
local function open_window(config)
  if result_window_valid() then
    focus_results()
    return
  end

  local current_window = api.nvim_get_current_win()
  if current_window ~= result_window then
    edit_window = current_window
  end
  local edit = get_edit_window()
  api.nvim_set_current_win(edit)
  local placement = config.win_pos == 'top' and 'leftabove' or 'rightbelow'
  vim.cmd(('%s %dsplit'):format(placement, config.win_size))
  result_window = api.nvim_get_current_win()

  if not result_buffer_valid() then
    result_buffer = api.nvim_create_buf(false, true)
    initialize_buffer(result_buffer)
  end

  local window = assert(result_window)
  local buffer = assert(result_buffer)
  api.nvim_win_set_buf(window, buffer)
  vim.wo.winfixheight = true
  vim.wo.cursorline = true
  vim.wo.number = true
  vim.wo.wrap = false
  vim.wo.signcolumn = 'no'
  vim.wo.statusline = ''

  if #api.nvim_buf_get_lines(buffer, 0, -1, false) == 0 then
    render(help_lines)
  end
end

---@param config GsearchResolvedConfig
local function search_command(pattern, config)
  local command = 'rg --no-heading --line-number --smart-case --no-ignore --hidden '
    .. vim.fn.shellescape(pattern)
  if config.globs ~= '' then
    command = command .. ' ' .. config.globs
  end
  return command
end

---@param pattern string
function M.search(pattern)
  if type(pattern) ~= 'string' then
    error 'gsearch: search pattern must be a string'
  end
  if vim.fn.executable 'rg' ~= 1 then
    vim.notify('gsearch: rg is not executable; install ripgrep first.', vim.log.levels.ERROR)
    return
  end

  local config = require('gsearch.config').get()
  vim.notify(('gsearch: search %s...(smart case)'):format(pattern), vim.log.levels.INFO)
  local output = vim.fn.system(search_command(pattern, config))
  local exit_code = vim.v.shell_error
  if exit_code ~= 0 and exit_code ~= 1 then
    vim.notify(('gsearch: ripgrep failed (exit %d)'):format(exit_code), vim.log.levels.ERROR)
  end

  confirmed_line = nil
  open_window(config)
  local matches = vim.split(output, '\n', { plain = true, trimempty = true })
  if config.enable_sort and #matches <= config.sort_lines_threshold then
    results.sort(matches)
  end

  local lines = vim.list_extend(vim.deepcopy(help_lines), {
    ('---------- %s ----------'):format(pattern),
  })
  vim.list_extend(lines, matches)
  render(lines)
  api.nvim_win_set_cursor(assert(result_window), { #help_lines + 1, 0 })
  vim.cmd 'normal! zz'
end

function M.open()
  open_window(require('gsearch.config').get())
end

function M.toggle()
  if result_window_valid() then
    M.close()
  else
    M.open()
  end
end

function M.toggle_help()
  if not result_buffer_valid() then
    return
  end

  local buffer = assert(result_buffer)
  local lines = api.nvim_buf_get_lines(buffer, #help_lines, -1, false)
  help_open = not help_open
  help_lines = help_open and vim.deepcopy(full_help) or vim.deepcopy(short_help)
  confirmed_line = nil
  render(vim.list_extend(vim.deepcopy(help_lines), lines))
  focus_results()
  api.nvim_win_set_cursor(assert(result_window), { 1, 0 })
end

function M.toggle_zoom()
  if not result_window_valid() then
    return
  end

  local config = require('gsearch.config').get()
  zoomed = not zoomed
  api.nvim_win_set_height(assert(result_window), zoomed and config.win_size_zoom or config.win_size)
end

---@param pattern string
---@param option 'pattern'|'file'
---@param reverse boolean
function M.filter(pattern, option, reverse)
  if pattern == '' then
    vim.notify(
      'gsearch: Search pattern is empty. Please provide your search pattern',
      vim.log.levels.WARN
    )
    return
  end
  if option ~= 'pattern' and option ~= 'file' then
    error "gsearch: filter option must be 'pattern' or 'file'"
  end
  if not result_buffer_valid() then
    return
  end

  local kept = {}
  local buffer = assert(result_buffer)
  local lines = api.nvim_buf_get_lines(buffer, #help_lines, -1, false)
  local header = nil
  if lines[1] and not results.parse(lines[1]) then
    header = table.remove(lines, 1)
  end

  for _, line in ipairs(lines) do
    local filename, _, text = results.parse(line)
    if filename then
      local subject = option == 'file' and filename or text
      local ok, matched = pcall(vim.fn.match, subject, pattern)
      if not ok then
        vim.notify(('gsearch: invalid filter pattern: %s'):format(pattern), vim.log.levels.ERROR)
        return
      end
      if (matched >= 0) ~= reverse then
        table.insert(kept, line)
      end
    end
  end

  confirmed_line = nil
  local filtered_lines = vim.deepcopy(help_lines)
  if header then
    table.insert(filtered_lines, header)
  end
  vim.list_extend(filtered_lines, kept)
  render(filtered_lines)
  focus_results()
  if #kept > 0 then
    api.nvim_win_set_cursor(assert(result_window), { #help_lines + 2, 0 })
  elseif header then
    api.nvim_win_set_cursor(assert(result_window), { #help_lines + 1, 0 })
  end
  vim.notify(('gsearch: Filter %s: %s'):format(option, pattern), vim.log.levels.INFO)
end

---@param preview? boolean
function M.select(preview)
  if not result_window_valid() then
    return
  end

  local window = assert(result_window)
  local buffer = assert(result_buffer)
  local cursor = api.nvim_win_get_cursor(window)
  local line = api.nvim_buf_get_lines(buffer, cursor[1] - 1, cursor[1], false)[1]
  local filename, line_number, text = results.parse(line)
  if not filename or not line_number or vim.fn.filereadable(filename) ~= 1 then
    vim.notify(('gsearch: %s not found!'):format(filename or line), vim.log.levels.WARN)
    return
  end

  confirmed_line = cursor[1]
  highlight(buffer)
  local edit = get_edit_window()
  api.nvim_set_current_win(edit)

  if preview then
    vim.cmd(('pedit +%d %s'):format(line_number, vim.fn.fnameescape(filename)))
    pcall(function()
      vim.cmd 'wincmd P'
    end)
    if vim.wo.previewwindow then
      api.nvim_buf_clear_namespace(0, target_namespace, 0, -1)
      add_highlight(0, target_namespace, 'GsearchTarget', api.nvim_win_get_cursor(0)[1] - 1, 0, -1)
      vim.cmd 'wincmd p'
    end
  else
    vim.cmd(('edit %s'):format(vim.fn.fnameescape(filename)))
    api.nvim_win_set_cursor(0, { math.min(line_number, api.nvim_buf_line_count(0)), 0 })
    if text and text ~= '' then
      local search_pattern = '\\V' .. vim.fn.escape(text, '\\')
      if vim.fn.search(search_pattern, 'cw') == 0 then
        vim.notify(('gsearch: Line pattern not found: %s'):format(text), vim.log.levels.WARN)
      end
    end
    vim.cmd 'normal! zz'
    api.nvim_buf_clear_namespace(0, target_namespace, 0, -1)
    add_highlight(0, target_namespace, 'GsearchTarget', api.nvim_win_get_cursor(0)[1] - 1, 0, -1)
  end

  focus_results()
end

return M
