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
                }
            end
        }
        use "kyazdani42/nvim-web-devicons"
        use "neovim/nvim-lspconfig"
        use {
            "hrsh7th/nvim-cmp",
            requires = {
                "neovim/nvim-lspconfig",
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/nvim-cmp"
            },
        }
        use "nvim-lua/lsp-status.nvim"
        use "simrat39/symbols-outline.nvim"
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
