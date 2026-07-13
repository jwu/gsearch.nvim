package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local results = require 'gsearch.results'

describe('gsearch results', function()
  it('parses ripgrep file, line, and text fields', function()
    local filename, line_number, text = results.parse 'lua/gsearch/init.lua:12:return M'

    assert.are.equal('lua/gsearch/init.lua', filename)
    assert.are.equal(12, line_number)
    assert.are.equal('return M', text)
  end)

  it('does not parse non-result lines', function()
    local filename, line_number, text = results.parse '---------- pattern ----------'

    assert.is_nil(filename)
    assert.is_nil(line_number)
    assert.is_nil(text)
  end)

  it('sorts results by file path and numeric line number', function()
    local sorted = results.sort({
      'b.lua:2:second',
      'a.lua:10:tenth',
      'a.lua:2:second',
    })

    assert.are.same({
      'a.lua:2:second',
      'a.lua:10:tenth',
      'b.lua:2:second',
    }, sorted)
  end)
end)
