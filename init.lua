-- [[ Setting options ]]
local user_home_dir = vim.fn.expand('$HOME') .. '/'
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.opt.pumheight = 15 -- max number of entries in completion window
vim.opt.guicursor:append('a:blinkon1')
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true -- Case-insensitive searching UNLESS \C or capital in search
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
-- vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = {
    tab = '» ',
    trail = '·',
    nbsp = '␣'
}
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.breakindent = true

-- [[ Basic Keymaps ]]
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {
    desc = 'Go to previous [D]iagnostic message'
})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {
    desc = 'Go to next [D]iagnostic message'
})
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {
    desc = 'Show diagnostic [E]rror messages'
})
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {
    desc = 'Open diagnostic [Q]uickfix list'
})

-- window management
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', {
    desc = 'Move focus to the left window'
})
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', {
    desc = 'Move focus to the right window'
})
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', {
    desc = 'Move focus to the lower window'
})
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', {
    desc = 'Move focus to the upper window'
})
vim.keymap.set('n', '<leader>o', 'o<Esc>', {
    desc = 'Insert a newline below the cursor'
})
vim.keymap.set('n', '<leader>O', 'O<Esc>', {
    desc = 'Insert a newline below the cursor'
})
vim.keymap.set('v', 'o', 'ozz', {
    desc = 'Other end of visual selection + center'
})

-- cycle buffers
vim.keymap.set('n', '<S-l>', ':bnext<CR>', {
    noremap = true,
    silent = true
})
vim.keymap.set('n', '<S-h>', ':bprev<CR>', {
    noremap = true,
    silent = true
})

-- vscode find all refs
vim.api.nvim_set_keymap('n', '<C-w>gr', "<Cmd>lua require('vscode').action('references-view.findReferences')<CR>", {
        noremap = true,
        silent = true
})

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- [[ Basic Autocommands ]]
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', {
        clear = true
    }),
    callback = function()
        vim.highlight.on_yank()
    end
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        '--branch=stable',
        lazyrepo,
        lazypath
    }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({
    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
    -- "gc" to comment visual regions/lines
    {
        'numToStr/Comment.nvim',
        opts = {}
    },
    { -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            ---@diagnostic disable-next-line: missing-fields
            require('nvim-treesitter.configs').setup {
                ensure_installed = {
                    'bash',
                    'c',
                    'html',
                    'lua',
                    'markdown',
                    'vim',
                    'vimdoc',
                    'python',
                    'toml',
                    'yaml',
                    'json',
                    'sql'
                },
                -- Autoinstall languages that are not installed
                auto_install = true,
                highlight = {
                    enable = not vim.g.vscode
                },
                indent = {
                    enable = true
                }
            }
        end
    },
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        opts = {}
    },
    { -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
                add = {
                    text = '+'
                },
                change = {
                    text = '~'
                },
                delete = {
                    text = '_'
                },
                topdelete = {
                    text = '‾'
                },
                changedelete = {
                    text = '~'
                }
            }
        }
    },
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        config = function()
            require'nvim-treesitter.configs'.setup {
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ['af'] = '@function.outer',
                            ['if'] = '@function.inner',
                            ['ac'] = '@class.outer',
                            ['ic'] = {
                                query = '@class.inner',
                                desc = 'Select inner part of a class region'
                            }
                        },
                        selection_modes = {
                            ['@parameter.outer'] = 'v', -- charwise
                            ['@function.outer'] = 'V', -- linewise
                            ['@class.outer'] = '<c-v>' -- blockwise
                        },
                        include_surrounding_whitespace = true
                    }
                }
            }
        end
    },
    {
        'windwp/nvim-autopairs',
        -- Optional dependency
        dependencies = {
            'hrsh7th/nvim-cmp'
        },
        config = function()
            require('nvim-autopairs').setup {}
            -- If you want to automatically add `(` after selecting a function or method
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')
            cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end
    },
    {
        'nvim-treesitter/nvim-treesitter-context'
    },
    {
        'ggandor/leap.nvim',
        config = function()
            vim.keymap.set({
                'n',
                'x',
                'o'
            }, 's', '<Plug>(leap-forward)')
            vim.keymap.set({
                'n',
                'o'
            }, 'S', '<Plug>(leap-backward)')
            vim.keymap.set({
                'n',
                'x',
                'o'
            }, 'gs', '<Plug>(leap-from-window)')
            require('leap').opts.special_keys.prev_target = ','
            require('leap').opts.special_keys.next_target = ';'
            require('leap').opts.special_keys.prev_group = '<bs>'
            require('leap.user').set_repeat_keys('<cr>', '<bs>')
            require('leap').opts.keys = {
                'S',
                mode = {
                    'n',
                    'x',
                    'o'
                },
                desc = 'Leap backward to'
            }
        end
    },
    {
        'navarasu/onedark.nvim',
        priority = 1000,
        config = function()
            require('onedark').setup {
                style = 'darker',
                code_style = {
                    comments = 'none'
                },
                colors = {
                    bg0 = '#0c0c0c',
                    fg = '#e4e7ed',
                    purple = '#c549eb',
                    green = '#91db58',
                    red = '#ff616d',
                    orange = '#ffae61',
                    grey = '#747d8f'
                },
                highlights = {
                    MatchParen = {
                        -- https://github.com/alacritty/alacritty/issues/2398
                        bg = '#666666',
                        fg = '#ffffff'
                    }
                }

            }
            vim.cmd.colorscheme 'onedark'
        end
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons'
        },
        config = function()
            require('lualine').setup {
                options = {
                    icons_enabled = false
                },
                sections = {
                    lualine_a = {
                        'mode'
                    },
                    lualine_b = {
                        'branch',
                        'diff',
                        'diagnostics'
                    },
                    lualine_c = {
                        {
                            'filename',
                            path = 1,
                            shorting_target = 70
                        }
                    },
                    lualine_x = {
                        'filetype'
                    },
                    lualine_y = {
                        'progress'
                    },
                    lualine_z = {
                        'location'
                    }
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {
                        'filename'
                    },
                    lualine_x = {
                        'location'
                    },
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {},
                winbar = {},
                inactive_winbar = {},
                extensions = {}
            }
        end
    },
    {
        'kylechui/nvim-surround',
        version = '*', -- Use for stability; omit to use `main` branch for the latest features
        config = function()
            require('nvim-surround').setup {}
        end
    },
    {
        'jpalardy/vim-slime',
        config = function()
            vim.cmd.xmap('<leader>a', '<Plug>SlimeRegionSend')
            vim.cmd.vmap('<leader>a', '<Plug>SlimeRegionSend')
            vim.cmd.nmap('<leader>a', '<Plug>SlimeParagraphSend')
            vim.cmd.nmap('<leader>a', '<Plug>SlimeSendCell')
            vim.g.slime_target = 'tmux'
            vim.g.slime_paste_file = user_home_dir .. '.slime_paste'
            vim.g.slime_cell_delimiter = '# %%'
            vim.g.slime_default_config = {
                socket_name = 'default',
                target_pane = '1'
            }
            vim.g.slime_bracketed_paste = 1
            vim.g.slime_dont_ask_default = 1
        end
    },
    { -- Useful plugin to show you pending keybinds.
        'folke/which-key.nvim',
        event = 'VimEnter', -- Sets the loading event to 'VimEnter'
        config = function() -- This is the function that runs, AFTER loading
            local wk = require('which-key')
            wk.setup()

            -- Document existing key chains
            wk.add({
                {
                    '<leader>c',
                    group = '[C]ode'
                },
                {
                    '<leader>c_',
                    hidden = true
                },
                {
                    '<leader>d',
                    group = '[D]ocument'
                },
                {
                    '<leader>d_',
                    hidden = true
                },
                {
                    '<leader>r',
                    group = '[R]ename'
                },
                {
                    '<leader>r_',
                    hidden = true
                },
                {
                    '<leader>s',
                    group = '[S]earch'
                },
                {
                    '<leader>s_',
                    hidden = true
                },
                {
                    '<leader>w',
                    group = '[W]orkspace'
                },
                {
                    '<leader>w_',
                    hidden = true
                }
            })
        end
    },
    { -- Fuzzy Finder (files, lsp, etc)
        'nvim-telescope/telescope.nvim',
        event = 'VimEnter',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { -- If encountering errors, see telescope-fzf-native README for install instructions
                'nvim-telescope/telescope-fzf-native.nvim',

                -- `build` is used to run some command when the plugin is installed/updated.
                -- This is only run then, not every time Neovim starts up.
                build = 'make',

                -- `cond` is a condition used to determine whether this plugin should be
                -- installed and loaded.
                cond = function()
                    return vim.fn.executable 'make' == 1
                end
            },
            {
                'nvim-telescope/telescope-ui-select.nvim'
            }, -- Useful for getting pretty icons, but requires a Nerd Font.
            {
                'nvim-tree/nvim-web-devicons',
                enabled = vim.g.have_nerd_font
            }
        },
        config = function()
            -- [[ Configure Telescope ]]
            require('telescope').setup {
                defaults = {
                    layout_config = {
                        horizontal = {
                            width = 0.75
                        }
                    },
                    path_display = {
                        'smart'
                    },
                    extensions = {
                        ['ui-select'] = {
                            require('telescope.themes').get_dropdown()
                        }
                    }
                }
            }

            -- Enable telescope extensions, if they are installed
            pcall(require('telescope').load_extension, 'fzf')
            pcall(require('telescope').load_extension, 'ui-select')

            -- See `:help telescope.builtin`
            local builtin = require 'telescope.builtin'
            vim.keymap.set('n', '<leader>sh', builtin.help_tags, {
                desc = '[S]earch [H]elp'
            })
            vim.keymap.set('n', '<leader>sk', builtin.keymaps, {
                desc = '[S]earch [K]eymaps'
            })
            vim.keymap.set('n', '<leader>sf', builtin.find_files, {
                desc = '[S]earch [F]iles'
            })
            vim.keymap.set('n', '<leader>ss', builtin.builtin, {
                desc = '[S]earch [S]elect Telescope'
            })
            vim.keymap.set('n', '<leader>sw', builtin.grep_string, {
                desc = '[S]earch current [W]ord'
            })
            vim.keymap.set('n', '<leader>sg', builtin.live_grep, {
                desc = '[S]earch by [G]rep'
            })
            vim.keymap.set('n', '<leader>sd', builtin.diagnostics, {
                desc = '[S]earch [D]iagnostics'
            })
            vim.keymap.set('n', '<leader>sr', builtin.resume, {
                desc = '[S]earch [R]esume'
            })
            vim.keymap.set('n', '<leader>s.', builtin.oldfiles, {
                desc = '[S]earch Recent Files ("." for repeat)'
            })
            vim.keymap.set('n', '<leader><leader>', builtin.buffers, {
                desc = '[ ] Find existing buffers'
            })

            -- Slightly advanced example of overriding default behavior and theme
            vim.keymap.set('n', '<leader>/', function()
                -- You can pass additional configuration to telescope to change theme, layout, etc.
                builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false
                })
            end, {
                desc = '[/] Fuzzily search in current buffer'
            })

            vim.keymap.set('n', '<leader>s/', function()
                builtin.live_grep {
                    grep_open_files = true,
                    prompt_title = 'Live Grep in Open Files'
                }
            end, {
                desc = '[S]earch [/] in Open Files'
            })

            -- Shortcut for searching your neovim configuration files
            vim.keymap.set('n', '<leader>sn', function()
                builtin.find_files {
                    cwd = vim.fn.stdpath 'config'
                }
            end, {
                desc = '[S]earch [N]eovim files'
            })
        end
    },
    {
        'neovim/nvim-lspconfig',
        config = function()
            if not vim.g.vscode then
                require('lspconfig').pyright.setup {}
                require('lspconfig').ruff.setup {}

                vim.api.nvim_create_autocmd('LspAttach', {
                    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
                    callback = function(ev)
                        -- Enable completion triggered by <c-x><c-o>
                        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                        -- Buffer local mappings.
                        -- See `:help vim.lsp.*` for documentation on any of the below functions
                        local opts = {
                            buffer = ev.buf
                        }

                        -- helper function
                        local map = function(keys, func, desc)
                            vim.keymap.set('n', keys, func, {
                                buffer = ev.buf,
                                desc = 'LSP: ' .. desc
                            })
                        end

                        --  To jump back, press <C-t>.
                        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
                        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
                        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
                        map('gh', vim.lsp.buf.hover, 'Hover Documentation')

                        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
                        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
                        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
                        vim.keymap.set('n', '<space>wl', function()
                            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                        end, opts)
                        vim.keymap.set('n', '<space>f', function()
                            vim.lsp.buf.format {
                                async = true
                            }
                        end, opts)

                        -- The following two autocommands are used to highlight references of the
                        -- word under your cursor when your cursor rests there for a little while.
                        -- When you move your cursor, the highlights will be cleared (the second autocommand).
                        local client = vim.lsp.get_client_by_id(ev.data.client_id)
                        if client and client.server_capabilities.documentHighlightProvider then
                            vim.api.nvim_create_autocmd({
                                'CursorHold',
                                'CursorHoldI'
                            }, {
                                buffer = ev.buf,
                                callback = vim.lsp.buf.document_highlight
                            })

                            vim.api.nvim_create_autocmd({
                                'CursorMoved',
                                'CursorMovedI'
                            }, {
                                buffer = ev.buf,
                                callback = vim.lsp.buf.clear_references
                            })
                        end
                    end
                })
            end
        end
    },
    { -- Autoformat
        'stevearc/conform.nvim',
        keys = {
            {
                -- Customize or remove this keymap to your liking
                '<leader>f',
                function()
                    require('conform').format({
                        async = true,
                        lsp_fallback = true
                    })
                end,
                mode = '',
                desc = 'Format buffer'
            }
        },
        opts = {
            notify_on_error = false,
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true
            },
            formatters_by_ft = {
                lua = {
                    'stylua'
                },
                python = {
                    'ruff_format',
                    'ruff_fix'
                }
            }
        }
    },
    { -- Autocompletion
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lsp-signature-help'
        },
        config = function()
            local cmp = require 'cmp'
            cmp.setup {
                completion = {
                    completeopt = 'menu,menuone,noinsert'
                },
                mapping = cmp.mapping.preset.insert {
                    -- Select the [n]ext item
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    -- Select the [p]revious item
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    -- Accept the completion.
                    ['<Tab>'] = cmp.mapping.confirm {
                        select = true
                    },
                    -- Manually trigger a completion from nvim-cmp.
                    ['<C-Space>'] = cmp.mapping.complete {}
                },
                sources = {
                    {
                        name = 'nvim_lsp'
                    },
                    {
                        name = 'nvim_lsp_signature_help'
                    },
                    {
                        name = 'path'
                    }
                }

            }
            -- Set up lspconfig.
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
            require('lspconfig')['pyright'].setup {
                capabilities = capabilities
            }
        end
    } --  Here are some example plugins that I've included in the kickstart repository.
    --  Uncomment any of the lines below to enable them (you will need to restart nvim).
    --
    -- require 'kickstart.plugins.debug',
    -- require 'kickstart.plugins.indent_line',
    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    This is the easiest way to modularize your config.
    --
    --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
}, {
    ui = {
        -- If you have a Nerd Font, set icons to an empty table which will use the
        -- default lazy.nvim defined Nerd Font icons otherwise define a unicode icons table
        icons = vim.g.have_nerd_font and {} or {
            cmd = '⌘',
            config = '🛠',
            event = '📅',
            ft = '📂',
            init = '⚙',
            keys = '🗝',
            plugin = '🔌',
            runtime = '💻',
            require = '🌙',
            source = '📄',
            start = '🚀',
            task = '📌',
            lazy = '💤 '
        }
    }
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
