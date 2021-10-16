vim.cmd [[packadd packer.nvim]]

return require("packer").startup(
    function()
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
            config = function()
            end
        }
        use "nvim-lua/lsp-status.nvim"
    end
)
