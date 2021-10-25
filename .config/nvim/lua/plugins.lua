vim.cmd [[packadd packer.nvim]]

return require("packer").startup(
    function(use)
        use "wbthomason/packer.nvim"
        use "movq/nvim-base16"
        use {
            "kyazdani42/nvim-tree.lua",
            requires = "kyazdani42/nvim-web-devicons",
            config = function()
                require "nvim-tree".setup {}
            end
        }
        use "kyazdani42/nvim-web-devicons"
        use "romgrk/barbar.nvim"
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
        use "nvim-treesitter/nvim-treesitter"
        use {
            "nvim-telescope/telescope.nvim",
            requires = {"nvim-lua/plenary.nvim"}
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
            "famiu/feline.nvim",
            config = function()
                local components = require('plugin_config.feline')
                require("feline").setup({
                    components = components,
                })
            end
        }
    end
)
