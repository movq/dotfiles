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
        use "simrat39/rust-tools.nvim"
        use {
            "hrsh7th/nvim-cmp",
            requires = {
                "neovim/nvim-lspconfig",
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/nvim-cmp"
            },
        }
        use "rcarriga/cmp-dap"
        use "nvim-lua/lsp-status.nvim"
        use "simrat39/symbols-outline.nvim"
        use "ray-x/lsp_signature.nvim"
        use "mfussenegger/nvim-dap"
        use "rcarriga/nvim-dap-ui"
        use "nvim-treesitter/nvim-treesitter"
        use {
            "nvim-telescope/telescope.nvim",
            requires = {"nvim-lua/plenary.nvim"},
        }
        use "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim"
        use "lewis6991/gitsigns.nvim"
        use "feline-nvim/feline.nvim"
    end
)
