if vim.g.loaded_gsearch then
  return
end

vim.g.loaded_gsearch = true

vim.api.nvim_set_hl(0, 'GsearchConfirm', { default = true, link = 'Visual' })
vim.api.nvim_set_hl(0, 'GsearchTarget', { default = true, link = 'Visual' })

-- exvim-lite-compatible defaults. They remain configurable without setup().
if vim.g.ex_search_winsize == nil then
  vim.g.ex_search_winsize = 15
end
if vim.g.ex_search_winsize_zoom == nil then
  vim.g.ex_search_winsize_zoom = 40
end
if vim.g.ex_search_winpos == nil then
  vim.g.ex_search_winpos = 'bottom'
end
if vim.g.ex_search_enable_sort == nil then
  vim.g.ex_search_enable_sort = 1
end
if vim.g.ex_search_sort_lines_threshold == nil then
  vim.g.ex_search_sort_lines_threshold = 100
end
if vim.g.ex_search_globs == nil then
  vim.g.ex_search_globs = ''
end

vim.api.nvim_create_user_command('GS', function(command)
  require('gsearch').search(command.args)
end, {
  nargs = 1,
  desc = 'Search the current working directory with ripgrep',
})

vim.api.nvim_create_user_command('EXSearchCWord', function()
  require('gsearch').search_cword()
end, {
  desc = 'Search for the word below the cursor with ripgrep',
})
