-- Search results centered please
vim.keymap.set('n', 'n', 'nzz', {silent = true})
vim.keymap.set('n', 'N', 'Nzz', {silent = true})
vim.keymap.set('n', '*', '*zz', {silent = true})
vim.keymap.set('n', '#', '#zz', {silent = true})
vim.keymap.set('n', 'g*', 'g*zz', {silent = true})
-- Very magic by default
vim.keymap.set('n', '?', '?\v')
vim.keymap.set('n', '/', '/\v')
-- insert mode to noemal mode on jj
vim.keymap.set('i', 'jj', '<ESC>', {silent = true})
vim.keymap.set('i', '<C-f>', '<C-g>U<Right>')
vim.keymap.set('i', '<C-f><C-f>', '<C-g>U<ESC><S-a>')
vim.keymap.set('n', 'H', '^')
vim.keymap.set('n', 'L', '$')
vim.keymap.set('v', 'H', '^')
vim.keymap.set('v', 'L', '$')
