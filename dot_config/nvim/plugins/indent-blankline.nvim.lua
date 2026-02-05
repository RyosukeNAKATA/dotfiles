vim.cmd ([[
augroup custom_highlight
  autocmd!
  set termguicolors
  set listchars=tab:»-,nbsp:¬,extends:»,precedes:«,trail:•,eol:↲
  set list
  au ColorScheme * highlight red guifg=#e27878 gui=nocombine
  au ColorScheme * highlight yellow guifg=#e2a478 gui=nocombine
  au ColorScheme * highlight green guifg=#b4be82 gui=nocombine
  au ColorScheme * highlight cyan guifg=#89b8c2 gui=nocombine
  au ColorScheme * highlight blue guifg=#84a0c6 gui=nocombine
  au ColorScheme * highlight magenta guifg=#a093c7 gui=nocombine
  augroup END
]])

-- indent-blankline.nvim v3 configuration
require("ibl").setup({
    indent = {
        char = "│",
        highlight = { "red", "yellow", "green", "cyan", "blue", "magenta" },
    },
    scope = {
        enabled = true,
    },
})