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
--インサートモードのままカーソル移動
vim.keymap.set('i', '<C-f>', '<C-g>U<Right>')
vim.keymap.set('i', '<C-f><C-f>', '<C-g>U<ESC><S-a>')
-- H/Lで行頭/末に移動
vim.keymap.set('n', 'H', '^')
vim.keymap.set('n', 'L', '$')
