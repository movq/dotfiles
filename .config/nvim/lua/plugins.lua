vim.g.symbols_outline = {
    symbol_blacklist = {"Variable"},
}
vim.cmd [[packadd packer.nvim]]

return require("packer").startup(
    function(use)
        use "wbthomason/packer.nvim"
        use "movq/nvim-base16"
        use {
	    "navarasu/onedark.nvim",
            config = function()
                require('onedark').setup {
                    style = 'darker',
                    colors = {
                        bg0 = '#080808'
                    }
                }
                require('onedark').load()
            end
        }
        use {
            "Pocco81/AutoSave.nvim",
            config = function()
                require "autosave".setup {}
            end
        }
        use {
            "kyazdani42/nvim-tree.lua",
            requires = "kyazdani42/nvim-web-devicons",
            config = function()
                require "nvim-tree".setup {
                    update_cwd = true,
                    view = {
                        mappings = {
                            list = {{ key = "<C-e>", action="" }},
                        },
                    },
                    filters = {
                        dotfiles = true,
                    }
                }
            end
        }
        use "kyazdani42/nvim-web-devicons"
        use "neovim/nvim-lspconfig"
        use "L3MON4D3/LuaSnip"
        use "saadparwaiz1/cmp_luasnip"
        use {
            "hrsh7th/nvim-cmp",
            requires = {
                "neovim/nvim-lspconfig",
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/nvim-cmp"
            },
            config = function()
                local cmp = require "cmp"
                cmp.setup(
                    {
                        snippet = {
                            expand = function(args)
                                require('luasnip').lsp_expand(args.body)
                            end,
                        },
                        mapping = cmp.mapping.preset.insert ({
                            ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                            ["<C-f>"] = cmp.mapping.scroll_docs(4),
                            ["<C-Space>"] = cmp.mapping.complete(),
                            ["<C-e>"] = cmp.mapping.close(),
                            ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                            }),
                        sources = {
                            {name = "nvim_lsp"},
                            {name = "luasnip"},
                            {name = "buffer"}
                        }
                    }
                )
            end
        }
        use "nvim-lua/lsp-status.nvim"
        use "simrat39/symbols-outline.nvim"
        use "mfussenegger/nvim-dap"
        use "nvim-treesitter/nvim-treesitter"
        use {
            "nvim-telescope/telescope.nvim",
            requires = {"nvim-lua/plenary.nvim"},
            commit = "80cdb00b221f69348afc4fb4b701f51eb8dd3120"
        }
        use {
            "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim",
            config = function()
                require('toggle_lsp_diagnostics').init({
                    update_in_insert = false,
                })
            end
        }
        use {
            "lewis6991/gitsigns.nvim",
            config = function()
                require("gitsigns").setup()
            end
        }
        use {
            "feline-nvim/feline.nvim",
            config = function()
                local components = require('plugin_config.feline')
                require("feline").setup({
                    components = components,
                })
            end
        }
    end
)
