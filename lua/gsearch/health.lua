local M = {}

function M.check()
  vim.health.start 'gsearch.nvim'
  vim.health.ok 'gsearch.nvim is available.'
end

return M
