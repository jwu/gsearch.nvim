package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

---@param path string
---@param content string
local function write_file(path, content)
  local file = assert(io.open(path, 'w'))
  file:write(content)
  file:close()
end

---@param path string
local function remove_directory(path)
  assert(os.execute(('rm -rf %q'):format(path)))
end

---@return string
local function project_directory()
  local process = assert(io.popen 'pwd')
  local directory = assert(process:read '*l')
  assert(process:close())
  return directory
end

describe('gsearch result undo', function()
  local directory

  before_each(function()
    directory = os.tmpname()
    os.remove(directory)
    assert(os.execute(('mkdir -p %q'):format(directory)))
  end)

  after_each(function()
    remove_directory(directory)
  end)

  it('restores filtered results and highlights with undo', function()
    write_file(directory .. '/a.txt', 'needle\n')
    local script = directory .. '/undo.lua'
    write_file(
      script,
      ([[
vim.opt.rtp:append(%q)
vim.cmd('cd ' .. vim.fn.fnameescape(%q))
vim.cmd 'runtime plugin/gsearch.lua'

local function feed(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'xt', false)
end

feed ':GS needle<CR>'
assert(vim.wait(1000, function()
  return vim.api.nvim_buf_get_name(0):match '%%[GSearch Results%%]' ~= nil
end))

local buffer = vim.api.nvim_get_current_buf()
local before = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
local function has_result_highlights()
  for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buffer, -1, 0, -1, { details = true })) do
    if mark[4].hl_group == 'Directory' then
      return true
    end
  end
  return false
end
assert(has_result_highlights())

feed ':D needle<CR>'
assert(vim.wait(1000, function()
  return #vim.api.nvim_buf_get_lines(buffer, 0, -1, false) < #before
end))
assert(
  vim.api.nvim_buf_get_lines(buffer, 2, 3, false)[1] == '---------- Exclude text: needle ----------',
  'filter header did not update'
)

feed 'u'
assert(vim.wait(1000, function()
  return vim.deep_equal(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), before)
    and has_result_highlights()
end), 'undo did not restore the result and its highlights')
]]):format(project_directory(), directory)
    )

    local process =
      assert(io.popen(("nvim --clean --headless '+lua dofile(%q)' +qa! 2>&1"):format(script)))
    local output = process:read '*a'
    assert(process:close(), output)
  end)
end)
