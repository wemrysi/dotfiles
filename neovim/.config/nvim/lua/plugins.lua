-- based on wbthomason's version at
-- https://github.com/wbthomason/dotfiles/blob/linux/neovim/.config/nvim/lua/plugins.lua

local packer = nil
local function init()
  if packer == nil then
    packer = require 'packer'
    packer.init {
      disable_commands = true,
      display = {
        open_fn = function()
          local result, win, buf = require('packer.util').float {
            border = {
              { '╭', 'FloatBorder' },
              { '─', 'FloatBorder' },
              { '╮', 'FloatBorder' },
              { '│', 'FloatBorder' },
              { '╯', 'FloatBorder' },
              { '─', 'FloatBorder' },
              { '╰', 'FloatBorder' },
              { '│', 'FloatBorder' },
            },
          }
          vim.api.nvim_win_set_option(win, 'winhighlight', 'NormalFloat:Normal')
          return result, win, buf
        end,
      }
    }
  end

  local use = packer.use
  packer.reset()

  -- Packer
  use 'wbthomason/packer.nvim'

  use 'lewis6991/impatient.nvim'

  -- Async building & commands
  use 'mhinz/vim-sayonara'

  -- Movement
  use 'chaoren/vim-wordmotion'
  use {
    {
      'ggandor/leap.nvim',
      requires = 'tpope/vim-repeat',
    },
    { 'ggandor/flit.nvim', config = [[require'flit'.setup { labeled_modes = 'nv' }]] },
  }

  -- Quickfix
  use { 'Olical/vim-enmasse', cmd = 'EnMasse' }
  use 'kevinhwang91/nvim-bqf'
  use {
    'https://gitlab.com/yorickpeterse/nvim-pqf',
    config = function()
      require('pqf').setup()
    end,
  }

  -- Indentation tracking
  use 'lukas-reineke/indent-blankline.nvim'

  -- Commenting
  -- use 'tomtom/tcomment_vim'
  use {
    'numToStr/Comment.nvim',
    event = 'User ActuallyEditing',
    config = function()
      require('Comment').setup {}
    end,
  }

  -- Wrapping/delimiters
  use {
    { 'machakann/vim-sandwich', event = 'User ActuallyEditing' },
    { 'andymass/vim-matchup', setup = [[require('config.matchup')]], event = 'User ActuallyEditing' },
  }

  -- Search
  use 'romainl/vim-cool'

  -- Text objects
  use 'wellle/targets.vim'

  -- Search
  use {
    {
      'nvim-telescope/telescope.nvim',
      branch = '0.1.x',
      requires = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
        'telescope-frecency.nvim',
        'telescope-fzf-native.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
      },
      wants = {
        'popup.nvim',
        'plenary.nvim',
        'telescope-frecency.nvim',
        'telescope-fzf-native.nvim',
      },
      setup = [[require('config.telescope_setup')]],
      config = [[require('config.telescope')]],
      cmd = 'Telescope',
      module = 'telescope',
    },
    {
      'nvim-telescope/telescope-frecency.nvim',
      after = 'telescope.nvim',
      requires = 'tami5/sqlite.lua',
    },
--  {
--    'nvim-telescope/telescope-fzf-native.nvim',
--    run = 'make',
--  },
    'crispgm/telescope-heading.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
  }

  -- Project Management/Sessions
  use {
    'dhruvasagar/vim-prosession',
    after = 'vim-obsession',
    requires = { 'tpope/vim-obsession', cmd = 'Prosession' },
    config = [[require('config.prosession')]],
  }

  -- Undo tree
  use {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    config = [[vim.g.undotree_SetFocusWhenToggle = 1]],
  }

  -- Git
  use {
    {
      'lewis6991/gitsigns.nvim',
      requires = 'nvim-lua/plenary.nvim',
      config = [[require('config.gitsigns')]],
      event = 'User ActuallyEditing',
    },
    { 'TimUntersberger/neogit', cmd = 'Neogit', config = [[require('config.neogit')]] },
    {
      'akinsho/git-conflict.nvim',
      tag = '*',
      config = function()
        require('git-conflict').setup()
      end,
    },
  }

  -- Pretty symbols
  use 'kyazdani42/nvim-web-devicons'

  -- REPLs
  use {
    'hkupty/iron.nvim',
    setup = [[vim.g.iron_map_defaults = 0]],
    config = [[require('config.iron')]],
    cmd = { 'IronRepl', 'IronSend', 'IronReplHere' },
  }

  -- Completion and linting
--use {
--  'neovim/nvim-lspconfig',
--  'folke/trouble.nvim',
--  'ray-x/lsp_signature.nvim',
--  {
--    'kosayoda/nvim-lightbulb',
--  },
--}

  -- Highlights
  use {
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'nvim-treesitter/nvim-treesitter-refactor',
      'RRethy/nvim-treesitter-textsubjects',
    },
    run = ':TSUpdate',
  }

  -- Documentation
  use {
    'danymat/neogen',
    requires = 'nvim-treesitter',
    config = [[require('config.neogen')]],
    keys = { '<localleader>d', '<localleader>df', '<localleader>dc' },
  }

  -- Snippets
  use {
    {
      'L3MON4D3/LuaSnip',
      opt = true,
    },
    'rafamadriz/friendly-snippets',
  }

  -- Completion
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
      'hrsh7th/cmp-nvim-lsp',
      'onsails/lspkind.nvim',
      { 'hrsh7th/cmp-nvim-lsp-signature-help', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' },
      { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
      'lukas-reineke/cmp-under-comparator',
      { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
    },
    config = [[require('config.cmp')]],
    event = 'InsertEnter',
    wants = 'LuaSnip',
  }

  -- Endwise
  use 'RRethy/nvim-treesitter-endwise'

  -- Path navigation
  use 'justinmk/vim-dirvish'
  use {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v2.x',
    config = [[vim.g.neo_tree_remove_legacy_commands = true]],
    requires = {
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
  }

  -- Highlight colors
  use {
    'norcalli/nvim-colorizer.lua',
    ft = { 'css', 'javascript', 'vim', 'html' },
    config = [[require('colorizer').setup {'css', 'javascript', 'vim', 'html'}]],
  }

  -- Buffer management
  use {
    'akinsho/bufferline.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = [[require('config.bufferline')]],
    event = 'User ActuallyEditing',
    disable = true,
  }

  use {
    'b0o/incline.nvim',
    config = [[require('config.incline')]],
    event = 'User ActuallyEditing',
  }

  use {
    'filipdutescu/renamer.nvim',
    branch = 'master',
    requires = { { 'nvim-lua/plenary.nvim' } },
    config = function()
      require('renamer').setup {}
    end,
  }

  use 'teal-language/vim-teal'
  use { 'jose-elias-alvarez/null-ls.nvim', requires = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' } }

  -- Pretty UI
  use 'stevearc/dressing.nvim'
  use 'rcarriga/nvim-notify'
  use 'vigoux/notifier.nvim'
  use {
    'folke/todo-comments.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('todo-comments').setup {}
    end,
  }

--use {
--  'j-hui/fidget.nvim',
--  config = function()
--    require('fidget').setup {
--      sources = {
--        ['null-ls'] = { ignore = true },
--      },
--    }
--  end,
--}

  use {
    'ethanholz/nvim-lastplace',
    config = function()
      require('nvim-lastplace').setup {}
    end,
  }
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    init()
    return packer[key]
  end,
})

return plugins
