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

Plug('folke/snacks.nvim');
Plug('davemo88/claudecode.nvim');

Plug('ibhagwan/fzf-lua');
Plug('pittcat/claude-fzf.nvim');

Plug 'stevearc/dressing.nvim'
Plug 'nvim-flutter/flutter-tools.nvim'

vim.call('plug#end')

vim.g.mapleader = ","

-- colors
vim.cmd[[colorscheme tokyonight-night]]

-- snacks.nvim configuration
if not vim.g.snacks_did_setup then
  require("snacks").setup({
    terminal = {
      win = {
        style = {
          wo = {
            winbar = "",  -- Hide the winbar which shows term://
          }
        }
      }
    }
  })
  vim.g.snacks_did_setup = true
end

-- claudecode
require('claudecode').setup({
  terminal = {
    split_side = "right",
    split_width_percentage = 0.5,
    provider = "auto",  -- Uses snacks.nvim when available
  },
  server = {
    auto_start = true,
    log_level = "info",
  },
  diff_opts = {
    vertical_split = false,
    keep_terminal_focus = true,
  },
})

vim.api.nvim_set_keymap('n', "<leader>cc", ':ClaudeCode<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', "<leader>ct", ':ClaudeCodeFocus<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', "<leader>cs", ':ClaudeCodeSend<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', "<Leader>w", '<C-\\><C-n><C-w>h'  , {noremap = true, silent = true})

-- claude-fzf.nvim
require('claude-fzf').setup({
  auto_context = true,
  batch_size = 10,
})

vim.api.nvim_set_keymap('n', '<leader>cf', ':ClaudeFzfFiles<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cg', ':ClaudeFzfGrep<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cb', ':ClaudeFzfBuffers<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cgf', ':ClaudeFzfGitFiles<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cd', ':ClaudeFzfDirectory<cr>', { noremap = true, silent = true })

-- Claude Code terminal-specific keybindings and cleanup
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    -- Hide statusline and set cleaner buffer name
    vim.opt_local.statusline = " "

    local bufname = vim.api.nvim_buf_get_name(0)
    -- Check if this is a Claude Code terminal buffer
    if bufname:match("claudecode") or bufname:match("ClaudeCode") or bufname:match("claude") then
      -- Rename the buffer to something cleaner
      pcall(vim.api.nvim_buf_set_name, 0, "Claude Code")

      -- Set buffer-local insert mode keymaps for quick window navigation
      vim.api.nvim_buf_set_keymap(0, 'i', '<C-w>h', '<Esc><C-w>h', { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(0, 'i', '<C-w>j', '<Esc><C-w>j', { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(0, 'i', '<C-w>k', '<Esc><C-w>k', { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(0, 'i', '<C-w>l', '<Esc><C-w>l', { noremap = true, silent = true })
    end
  end,
})

-- Terminal mode window navigation
vim.api.nvim_set_keymap('t', '<C-w>h', '<C-\\><C-n><C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-w>j', '<C-\\><C-n><C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-w>k', '<C-\\><C-n><C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-w>l', '<C-\\><C-n><C-w>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', "<Leader><Esc>", '<C-\\><C-n>'  , {noremap = true, silent = true})

-- completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- rustaceanvim configuration
vim.g.rustaceanvim = {
  server = {
    capabilities = capabilities,
  },
}

-- completion
require'cmp'.setup {
  sources = {
    { name = 'nvim_lsp' }
  }
}

require("typescript-tools").setup{
  capabilities = capabilities,
}

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "typescript", "typescriptreact", "dart" },
    callback = function()
        vim.bo.tabstop = 2
        vim.bo.shiftwidth = 2
        vim.bo.expandtab = true
    end,
})

require("flutter-tools").setup {
  lsp = {
    capabilities = capabilities,
  }
}

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "dart" },
    callback = function()
        vim.bo.tabstop = 2
        vim.bo.shiftwidth = 2
        vim.bo.expandtab = true
    end,
})

-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
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

vim.env.FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'

-- Floating terminal (persistent)
local term_buf = nil
local term_win = nil

vim.api.nvim_create_user_command('Term', function()
  -- If window is open, close it
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, false)
    term_win = nil
    return
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)

  -- Check if buffer exists and is valid
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    -- Reopen window with existing buffer
    term_win = vim.api.nvim_open_win(term_buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      col = math.floor((vim.o.columns - width) / 2),
      row = math.floor((vim.o.lines - height) / 2),
      style = 'minimal',
      border = 'rounded',
    })
  else
    -- Create new buffer and terminal
    term_buf = vim.api.nvim_create_buf(false, true)
    term_win = vim.api.nvim_open_win(term_buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      col = math.floor((vim.o.columns - width) / 2),
      row = math.floor((vim.o.lines - height) / 2),
      style = 'minimal',
      border = 'rounded',
    })
    vim.fn.termopen(vim.o.shell)
  end
  vim.cmd('startinsert')
end, {})

vim.keymap.set('n', '<leader>t', ':Term<CR>', { silent = true })
vim.keymap.set('t', '<leader>t', '<C-\\><C-n>:Term<CR>', { silent = true })

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- Check if there are no files in the arguments
        if vim.fn.argc() == 0 then
            vim.cmd("ClaudeCode")
            vim.cmd("FZF")
        end
    end,
})
