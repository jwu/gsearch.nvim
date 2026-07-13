local M = {}

---@param line string
---@return string|nil filename
---@return integer|nil line_number
---@return string|nil text
function M.parse(line)
  local filename, line_number, text = line:match '^(.-):(%d+):(.*)$'
  if not filename then
    return nil, nil, nil
  end

  return filename, tonumber(line_number), text
end

---@param lines string[]
---@return string[]
function M.sort(lines)
  table.sort(lines, function(left, right)
    local left_file, left_line = M.parse(left)
    local right_file, right_line = M.parse(right)

    if not left_file then
      return false
    end
    if not right_file then
      return true
    end
    if left_file ~= right_file then
      return left_file < right_file
    end
    return left_line < right_line
  end)

  return lines
end

return M
