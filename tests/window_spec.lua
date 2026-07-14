package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

describe('gsearch window', function()
  local previous_vim
  local previous_win_buf_op
  local previous_win_buf_op_preload

  before_each(function()
    previous_vim = _G.vim
    previous_win_buf_op = package.loaded['win-buf-op']
    previous_win_buf_op_preload = package.preload['win-buf-op']
    package.loaded['gsearch.window'] = nil
  end)

  after_each(function()
    _G.vim = previous_vim
    package.loaded['win-buf-op'] = previous_win_buf_op
    package.preload['win-buf-op'] = previous_win_buf_op_preload
    package.loaded['gsearch.window'] = nil
  end)

  local function set_vim(windows, buftypes, current_window, alternate_window)
    _G.vim = {
      api = {
        nvim_get_current_win = function()
          return current_window
        end,
        nvim_win_is_valid = function(window)
          return buftypes[window] ~= nil
        end,
        nvim_win_get_buf = function(window)
          return window
        end,
        nvim_get_option_value = function(_, options)
          return buftypes[options.buf]
        end,
        nvim_tabpage_list_wins = function()
          return windows
        end,
      },
      fn = {
        win_getid = function()
          return alternate_window
        end,
        winnr = function()
          return 1
        end,
      },
    }
  end

  it('uses win-buf-op last_edit_window when available', function()
    set_vim({ 1, 2 }, { [1] = '', [2] = '' }, 1, 1)
    package.loaded['win-buf-op'] = {
      last_edit_window = function()
        return 2
      end,
    }

    local window = require('gsearch.window').last_edit_window()

    assert.are.equal(2, window)
  end)

  it('uses the current editing window when win-buf-op is unavailable', function()
    set_vim({ 1, 2 }, { [1] = '', [2] = '' }, 2, 1)
    package.preload['win-buf-op'] = function()
      error 'win-buf-op is not installed'
    end

    local window = require('gsearch.window').last_edit_window()

    assert.are.equal(2, window)
  end)

  it('falls back to the alternate editing window', function()
    set_vim({ 1, 2, 3 }, { [1] = 'nofile', [2] = '', [3] = '' }, 1, 3)
    package.preload['win-buf-op'] = function()
      error 'win-buf-op is not installed'
    end

    local window = require('gsearch.window').last_edit_window()

    assert.are.equal(3, window)
  end)

  it('falls back to the first editing window when alternate is extended', function()
    set_vim({ 1, 2, 3 }, { [1] = 'nofile', [2] = '', [3] = '' }, 1, 1)
    package.preload['win-buf-op'] = function()
      error 'win-buf-op is not installed'
    end

    local window = require('gsearch.window').last_edit_window()

    assert.are.equal(2, window)
  end)
end)
