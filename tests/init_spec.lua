package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

describe('gsearch', function()
  it('exposes a module table', function()
    local gsearch = require 'gsearch'

    assert.are.equal('table', type(gsearch))
  end)

  it('registers search commands without legacy global defaults', function()
    local commands = {}
    local previous_vim = _G.vim
    local previous_gsearch = package.loaded.gsearch
    local searches = {}

    _G.vim = {
      g = {},
      api = {
        nvim_set_hl = function() end,
        nvim_create_user_command = function(name, callback, options)
          commands[name] = { callback = callback, options = options }
        end,
      },
    }
    package.loaded.gsearch = {
      search = function(pattern)
        table.insert(searches, pattern)
      end,
      search_cword = function()
        table.insert(searches, 'cword')
      end,
    }

    dofile 'plugin/gsearch.lua'

    assert.is_truthy(commands.GS)
    assert.is_truthy(commands.GSearchCWord)
    assert.is_nil(commands.EXSearchCWord)
    assert.are.equal(1, commands.GS.options.nargs)
    assert.is_nil(vim.g.ex_search_winsize)
    assert.is_nil(vim.g.ex_search_winsize_zoom)
    assert.is_nil(vim.g.ex_search_winpos)
    assert.is_nil(vim.g.ex_search_enable_sort)
    assert.is_nil(vim.g.ex_search_sort_lines_threshold)
    assert.is_nil(vim.g.ex_search_globs)

    commands.GS.callback({ args = 'needle' })
    commands.GSearchCWord.callback()
    assert.are.same({ 'needle', 'cword' }, searches)

    _G.vim = previous_vim
    package.loaded.gsearch = previous_gsearch
  end)
end)
