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
--$B%$%s%5!<%H%b!<%I$N$^$^%+!<%=%k0\F0(B
vim.keymap.set('i', '<C-f>', '<C-g>U<Right>')
vim.keymap.set('i', '<C-f><C-f>', '<C-g>U<ESC><S-a>')
-- H/L$B$G9TF,(B/$BKv$K0\F0(B
vim.keymap.set('n', 'H', '^')
vim.keymap.set('n', 'L', '$')
