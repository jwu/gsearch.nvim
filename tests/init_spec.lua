package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

describe('gsearch', function()
  it('exposes a module table', function()
    local gsearch = require 'gsearch'

    assert.are.equal('table', type(gsearch))
  end)
end)
