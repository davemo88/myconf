local vim = vim
local Plug = vim.fn['plug#']

-- plugins
vim.call('plug#begin')

Plug('junegunn/fzf', { ['do'] = vim.fn['fzf#install']});
Plug('junegunn/fzf.vim');

Plug('neovim/nvim-lspconfig');
Plug('nvim-lua/plenary.nvim');
Plug('pmizio/typescript-tools.nvim');

Plug('nvim-treesitter/nvim-treesitter', {['do'] = vim.fn[':TSUpdate']});
Plug('nvim-treesitter/nvim-treesitter-context'); 

Plug('mfussenegger/nvim-dap');
Plug('rcarriga/nvim-dap-ui');

Plug('mrcjkb/rustaceanvim');

Plug('hashivim/vim-terraform');

Plug('folke/tokyonight.nvim');

Plug('hrsh7th/cmp-path');
Plug('hrsh7th/cmp-buffer');
Plug('hrsh7th/cmp-cmdline');
Plug('hrsh7th/cmp-nvim-lsp');
Plug('hrsh7th/cmp-vsnip');
Plug('hrsh7th/vim-vsnip');
Plug('hrsh7th/nvim-cmp');

Plug('Canop/nvim-bacon');
Plug('stevearc/aerial.nvim');

vim.call('plug#end')

-- colors
vim.cmd[[colorscheme tokyonight-night]]

-- completion
require'cmp'.setup {
  sources = {
    { name = 'nvim_lsp' }
  }
}

vim.api.nvim_create_autocmd("FileType", {
    pattern = "typescriptreact",
    callback = function()
        vim.bo.tabstop = 2
        vim.bo.shiftwidth = 2
        vim.bo.expandtab = true
    end,
})

-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },

  -- Installed sources
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'buffer' },
  },
})

require("aerial").setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
})

-- keybindings
vim.g.mapleader = ","

vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('Q', 'q', {})

vim.api.nvim_set_keymap('n', '<leader>f', ':FZF<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>F', ':FZF ~<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>r', ':Rg<cr>', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")

vim.keymap.set("v", "<leader>y", '"+y', { noremap = true })
vim.keymap.set("n", "<leader>Y", '"+yg_', { noremap = true })
vim.keymap.set("n", "<leader>y", '"+y', { noremap = true })
vim.keymap.set("n", "<leader>yy", '"+yy', { noremap = true })
vim.keymap.set("n", "<leader>p", '"+p', { noremap = true })
vim.keymap.set("n", "<leader>P", '"+P', { noremap = true })
vim.keymap.set("v", "<leader>p", '"+p', { noremap = true })
vim.keymap.set("v", "<leader>P", '"+P', { noremap = true })

vim.env.FZF_DEFAULT_COMMAND = 'fd --type f'

vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.implementation()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gn', '<cmd>lua vim.lsp.buf.type_definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'g0', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gW', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gR', '<cmd>lua vim.lsp.buf.rename()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })

vim.o.updatetime = 300
vim.api.nvim_create_autocmd("CursorHold", {
    pattern = "*",
    callback = function()
        vim.diagnostic.open_float(nil, { focusable = false })
    end,
})

-- grep
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"

-- fixed gutter
vim.opt.signcolumn = "yes"

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- Check if there are no files in the arguments
        if vim.fn.argc() == 0 then
            vim.cmd("FZF")
        end
    end,
})
