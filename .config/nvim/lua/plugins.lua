return require("packer").startup(
    function(use)
        use "wbthomason/packer.nvim"
        use "movq/nvim-base16"
        use "navarasu/onedark.nvim"
        use "Pocco81/AutoSave.nvim"
        use "kyazdani42/nvim-tree.lua"
        use "kyazdani42/nvim-web-devicons"
        use "neovim/nvim-lspconfig"
        use "L3MON4D3/LuaSnip"
        use "saadparwaiz1/cmp_luasnip"
        use "p00f/clangd_extensions.nvim"
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
                            ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                        }),
                        sources = {
                            {name = "nvim_lsp"},
                            {name = "luasnip"},
                            {name = "buffer"}
                        },
                        sorting = {
                            comparators = {
                                cmp.config.compare.locality,
                                cmp.config.compare.recently_used,
                                require('clangd_extensions.cmp_scores'),
                                cmp.config.compare.score,
                                cmp.config.compare.offset,
                                cmp.config.compare.order,
                            }
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
        use "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim"
        use "lewis6991/gitsigns.nvim"
        use "feline-nvim/feline.nvim"
    end
)
