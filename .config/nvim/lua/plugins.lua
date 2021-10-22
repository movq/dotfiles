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
        use "junegunn/fzf.vim"
        use {
            "romgrk/barbar.nvim",
            requires = {"kyazdani42/nvim-web-devicons"}
        }
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
                require('toggle_lsp_diagnostics').init()
            end
        }
        use {
            "famiu/feline.nvim",
            config = function()
                require("feline").setup()
            end
        }
    end
)
