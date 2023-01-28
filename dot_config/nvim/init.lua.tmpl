vim.api.nvim_set_var('dein#auto_recache', 1)
vim.api.nvim_set_var('dein#lazy_rplugins', 1)
vim.api.nvim_set_var('dein#enable_notification', 1)
vim.api.nvim_set_var('dein#install_max_processes', 16)
vim.api.nvim_set_var('dein#install_message_type', 'none')
vim.api.nvim_set_var('dein#enable_notification', 1)

local dein_dir = vim.env.HOME .. '/.cache/dein'
local dein_repo_dir = dein_dir .. '/repos/github.com/Shougo/dein.vim'

if not string.match(vim.o.runtimepath, '/dein.vim') then
    if vim.fn.isdirectory(dein_repo_dir) ~= 1 then
        os.execute('git clone https://github.com/Shougo/dein.vim ' .. dein_repo_dir)
    end
    vim.o.runtimepath = dein_repo_dir .. ',' .. vim.o.runtimepath
end

if vim.call('dein#load_state', dein_dir) == 1 then
    local dein_toml_dir = vim.env.HOME .. '/dotfiles/.config/nvim'
    local dein_toml = dein_toml_dir .. '/dein.toml'
    local dein_toml_lazy = dein_toml_dir .. '/dein_lazy.toml'

    vim.call('dein#begin', dein_dir, { vim.fn.expand('<sfile>'), dein_toml, dein_toml_lazy, dein_toml_input })
    vim.call('dein#load_toml', dein_toml, { lazy = 0 })
    vim.call('dein#load_toml', dein_toml_lazy, { lazy = 1 })
    vim.call('dein#end')
    vim.call('dein#save_state')
end

-- load other settings
require('keymap')
require('lsp')
require('opt')

vim.api.nvim_command [[colorscheme iceberg]]
vim.api.nvim_create_autocmd(
    "ColorScheme",
    { pattern = "*", command = "hi ColorColumn gui=reverse cterm=italic" }
)
-- cofign for nvim-lastplace
require 'nvim-lastplace'.setup {
    lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
    lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
    lastplace_open_folds = true
}
