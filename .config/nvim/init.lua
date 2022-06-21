require('plugins')

vim.g.mapleader = ","

 -- Just Dvorak things
vim.api.nvim_set_keymap("", "t", "k", { noremap = true })
vim.api.nvim_set_keymap("", "n", "j", { noremap = true })
vim.api.nvim_set_keymap("", "j", "n", { noremap = true })
vim.api.nvim_set_keymap("", "s", "l", { noremap = true })
vim.api.nvim_set_keymap("", "l", "s", { noremap = true })

vim.api.nvim_set_keymap("i", "hh", "<Esc>", { noremap = true })
vim.api.nvim_set_keymap("n", ";", ":", { noremap = true })

vim.api.nvim_set_keymap("", "<C-h>", "<C-w>h", { noremap = true })
vim.api.nvim_set_keymap("", "<C-n>", "<C-w>j", { noremap = true })
vim.api.nvim_set_keymap("", "<C-t>", "<C-w>k", { noremap = true })
vim.api.nvim_set_keymap("", "<C-s>", "<C-w>l", { noremap = true })

vim.api.nvim_set_keymap("n", "<C-w>", ":bp|bd#<CR>", { noremap = true})

vim.api.nvim_set_keymap("n", "<C-e>", ":NvimTreeToggle<CR>", { noremap = true})
vim.api.nvim_set_keymap("n", "<leader>r", ":NvimTreeRefresh<CR>", { noremap = true})
vim.api.nvim_set_keymap("n", "<leader>n", ":NvimTreeFindFile<CR>", { noremap = true})

vim.api.nvim_set_keymap("n", "<C-p>", ":Telescope find_files<CR>", { noremap = true})
vim.api.nvim_set_keymap("n", "<leader>p", ":Telescope buffers<CR>", { noremap = true})
vim.api.nvim_set_keymap("n", "<C-j>", ":Telescope lsp_document_symbols <CR>", { noremap = true})
vim.api.nvim_set_keymap("n", "<C-k>", ":Telescope lsp_workspace_symbols <CR>", { noremap = true})

vim.api.nvim_set_keymap("n", "<C-l>", ":SymbolsOutline<CR>", { noremap = true})

vim.api.nvim_set_keymap("n", "<leader>td", "<Plug>(toggle-lsp-diag)", { noremap = true})

-- DAP
vim.api.nvim_set_keymap("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", { noremap = true})
vim.api.nvim_set_keymap("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", { noremap = true})
vim.api.nvim_set_keymap("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", { noremap = true})
vim.api.nvim_set_keymap("n", "<F12>", "<Cmd>lua require'dap'.step_out()<CR>", { noremap = true})
vim.api.nvim_set_keymap("n", "<leader>b", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", { noremap = true})
vim.api.nvim_set_keymap("n", "<leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>", { noremap = true})

vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.wildmode = "longest,list,full"
vim.opt.wildmenu = true
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.mouse = "a"

vim.opt.clipboard = "unnamedplus"
vim.opt.hidden = true
vim.opt.cursorline = true
vim.opt.hlsearch = false

vim.cmd("autocmd FileType text lua require 'cmp'.setup.buffer { sources = {} }")
vim.cmd("autocmd FileType yaml setlocal indentkeys-=0#")

---------------------------------------------------------------------------------------------------

require('onedark').setup {
    style = 'darker',
    colors = {
        bg0 = '#080808'
    }
}
require('onedark').load()
vim.cmd("highlight ExtraWhitespace guibg=red")
vim.cmd("match ExtraWhitespace /\\s\\+$/")
vim.cmd("highlight NvimTreeSpecialFile guifg='#f0c674'")
vim.cmd("highlight NvimTreeRootFolder guifg='#b294bb'")

require('autosave').setup {}

require('nvim-tree').setup {
    update_cwd = true,
    view = {
        mappings = {
            list = {{ key = "<C-e>", action="" }},
        },
    },
    filters = {
        dotfiles = true,
    },
}

require('toggle_lsp_diagnostics').init {
    update_in_insert = false,
}

require('gitsigns').setup()

require('feline').setup({
    components = require('plugin_config.feline')
})

require('telescope').setup {
  pickers = {
    buffers = {
      sort_lastused = true
    }
  }
}

vim.g.symbols_outline = {
    symbol_blacklist = {"Variable"},
}

---------------------------------------------------------------------------------------------------

local nvim_lsp = require("lspconfig")

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    -- Mappings.
    local opts = {noremap = true, silent = true}

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    buf_set_keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    buf_set_keymap("n", "k", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    buf_set_keymap("i", "<C-p>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    -- buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    -- buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    -- buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
    buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    buf_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
    buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
    buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
    -- buf_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.set_loclist()<CR>", opts)
    -- buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

require "clangd_extensions".setup {
    server = {
        cmd = {"/home/mike/.local/bin/runlsp.sh", "clangd-14"},
        on_attach = on_attach,
        capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
    },
}
nvim_lsp["pyright"].setup {
    on_attach = on_attach,
    flags = {
        debounce_text_changes = 150
    },
    capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
}

nvim_lsp["rust_analyzer"].setup {
    on_attach = on_attach,
    flags = {
        debounce_text_changes = 150
    },
    capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
}

-- Lua LSP stuff
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
nvim_lsp["sumneko_lua"].setup {
    cmd = {"lua-language-server", "-E", vim.env.HOME .. "/src/lua-language-server/main.lua"},
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
                -- Setup your lua path
                path = runtime_path
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {"vim"}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true)
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false
            }
        }
    },
    on_attach = on_attach,
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
}

require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        "c", "cpp", "rust", "cuda", "go", "javascript", "lua",
        "python", "typescript", "vim", "yaml", "haskell"
    },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

local dap = require('dap')
dap.adapters.python = {
  type = 'executable';
  command = 'python',
  args = { '-m', 'debugpy.adapter' };
}
dap.configurations.python = {
  {
    type = 'python';
    request = 'launch';
    name = "Launch file";
    program = "${file}";
    pythonPath = function()
      return '/usr/bin/python'
    end;
  },
}
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
  name = 'lldb'
}
dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
  }
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
