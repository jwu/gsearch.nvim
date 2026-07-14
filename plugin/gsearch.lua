if vim.g.loaded_gsearch then
  return
end

vim.g.loaded_gsearch = true

vim.api.nvim_set_hl(0, 'GsearchConfirm', { default = true, link = 'Visual' })
vim.api.nvim_set_hl(0, 'GsearchTarget', { default = true, link = 'Visual' })

vim.api.nvim_create_user_command('GS', function(command)
  require('gsearch').search(command.args)
end, {
  nargs = 1,
  desc = 'Search the current working directory with ripgrep',
})

vim.api.nvim_create_user_command('GSearchCWord', function()
  require('gsearch').search_cword()
end, {
  desc = 'Search for the word below the cursor with ripgrep',
})
