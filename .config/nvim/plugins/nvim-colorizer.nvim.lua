vim.cmd ([[
  augroup custom_highlight
    autocmd!
	:lua require'colorizer'.setup()
  augroup END
]])
