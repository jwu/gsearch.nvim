local M = {}

function M.check()
  vim.health.start 'gsearch.nvim'
  vim.health.info 'Searches run from Neovim’s current working directory.'

  if vim.fn.executable 'rg' == 1 then
    vim.health.ok 'ripgrep (rg) is executable.'
  else
    vim.health.error('ripgrep (rg) is not executable.', {
      'Install ripgrep and ensure `rg` is on $PATH.',
    })
  end
end

return M
