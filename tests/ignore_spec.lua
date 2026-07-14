package.path = './lua/?.lua;./lua/?/init.lua;' .. package.path

local ignore = require 'gsearch.ignore'

---@param path string
local function write_file(path)
  local file = assert(io.open(path, 'w'))
  file:close()
end

---@param path string
local function remove_directory(path)
  assert(os.execute(('rm -rf %q'):format(path)))
end

describe('gsearch ignore files', function()
  local directory

  before_each(function()
    directory = os.tmpname()
    os.remove(directory)
    assert(os.execute(('mkdir -p %q'):format(directory)))
  end)

  after_each(function()
    remove_directory(directory)
  end)

  it('selects the highest-priority ignore file', function()
    write_file(directory .. '/.gitignore')
    assert.are.equal(directory .. '/.gitignore', ignore.find(directory))

    write_file(directory .. '/.ignore')
    assert.are.equal(directory .. '/.ignore', ignore.find(directory))

    write_file(directory .. '/.rgignore')
    assert.are.equal(directory .. '/.rgignore', ignore.find(directory))
  end)

  it('returns nil when the directory has no ignore file', function()
    assert.is_nil(ignore.find(directory))
  end)
end)
