local vim = vim
local Plug = vim.fn['plug#']

-- plugins
vim.call('plug#begin')

Plug('junegunn/fzf', { ['do'] = vim.fn['fzf#install']})

Plug('nvim-treesitter/nvim-treesitter', {['do'] = vim.fn[':TSUpdate']});
Plug('nvim-treesitter/nvim-treesitter-context'); 

Plug('mfussenegger/nvim-dap');

Plug('mrcjkb/rustaceanvim');

vim.call('plug#end')


-- keybindings
vim.g.mapleader = ","
-- Key mappings for FZF and Rg
vim.api.nvim_set_keymap('n', '<leader>f', ':FZF<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>F', ':FZF ~<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>r', ':Rg<cr>', { noremap = true, silent = true })

