local M = {}

local priority = { '.rgignore', '.ignore', '.gitignore' }

---@param directory string
---@return string|nil
function M.find(directory)
  local separator = '/'
  local suffix = directory:sub(-1) == separator and '' or separator

  for _, filename in ipairs(priority) do
    local path = directory .. suffix .. filename
    local file = io.open(path, 'r')
    if file then
      file:close()
      return path
    end
  end
end

return M
