vim.g.mapleader = ","

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

vim.api.nvim_set_keymap("n", "<C-w>", ":bp|bd#<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "]b", ":bnext<CR>", {})
vim.api.nvim_set_keymap("n", "[b", ":bprevious<CR>", {})
vim.api.nvim_set_keymap("n", "[q", ":quit<CR>", {})

vim.api.nvim_set_keymap("n", "<C-e>", ":Neotree toggle<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-a>", ":Neotree buffers toggle<CR>", { noremap = true })

vim.api.nvim_set_keymap("n", "<C-p>", ":Telescope find_files<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>p", ":Telescope buffers<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-j>", ":Telescope lsp_document_symbols <CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-k>", ":Telescope lsp_workspace_symbols <CR>", { noremap = true })

vim.api.nvim_set_keymap("n", "<C-l>", ":SymbolsOutline<CR>", { noremap = true })

vim.keymap.set("n", "<leader>td", function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end, { silent = true, noremap = true })

vim.api.nvim_set_keymap("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<F12>", "<Cmd>lua require'dap'.step_out()<CR>", { noremap = true })

vim.api.nvim_set_keymap("n", "<leader>b", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>dk", "<Cmd>lua require'dapui'.eval()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>dt", "<Cmd>lua require'dapui'.toggle()<CR>", { noremap = true })

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
vim.opt.wrap = false

vim.g.rust_recommended_style = false

vim.cmd("autocmd FileType text lua require 'cmp'.setup.buffer { sources = {} }")
vim.cmd("autocmd FileType yaml setlocal indentkeys-=0#")

---------------------------------------------------------------------------------------------------

require("onedark").setup({
	style = "darker",
	colors = {
		bg0 = "#000000",
		bg1 = "#151515",
	},
})
require("onedark").load()
require("auto-save").setup()

vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
require("auto-session").setup({
    suppressed_dirs = { "~/", "~/src", "~/data", "~/downloads", "/"},
})

local lualine_custom_onedark = require("lualine.themes.onedark")

lualine_custom_onedark.normal.a.bg = '#000000'
lualine_custom_onedark.normal.a.fg = '#c6c8c6'
lualine_custom_onedark.normal.b.bg = '#000000'
lualine_custom_onedark.normal.c.bg = '#000000'
lualine_custom_onedark.insert.a.bg = '#000000'
lualine_custom_onedark.insert.a.fg = '#c6c8c6'
lualine_custom_onedark.visual.a.bg = '#000000'
lualine_custom_onedark.command.a.bg = '#000000'
lualine_custom_onedark.command.a.fg = '#c6c8c6'

require("lualine").setup({
    options = {
        theme = lualine_custom_onedark,
        component_separators = { left = ' ', right = ' '},
        section_separators = { left = ' ', right = ' '},
    },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'filename'},
    lualine_c = {'diff', 'diagnostics'},
    lualine_x = {'branch', 'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
})

require("neo-tree").setup({
    source_selector = {
        winbar = true,
        statusline = false,
        sources = {
          { source = "filesystem" },
          { source = "buffers" },
          { source = "document_symbols" },
          -- { source = "git_status" },
        },
    },
    window = {
        width = 30,
    },
    filesystem = {
        follow_current_file = {
            enabled = true,
        },
    },
    buffers = {
        follow_current_file = {
            enabled = true,
        },
    },
    sources = {"filesystem", "buffers", "document_symbols"},
      mappings = {
        ["<C-a>"] = "close_window",
        ["<C-e>"] = "close_window",
        ["<space>"] = {
            "toggle_node",
            nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use 
        },
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["<esc>"] = "cancel", -- close preview or floating neo-tree window
        ["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
        -- Read `# Preview Mode` for more information
        ["l"] = "focus_preview",
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        -- ["S"] = "split_with_window_picker",
        -- ["s"] = "vsplit_with_window_picker",
        ["t"] = "open_tabnew",
        -- ["<cr>"] = "open_drop",
        -- ["t"] = "open_tab_drop",
        ["w"] = "open_with_window_picker",
        --["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
        ["C"] = "close_node",
        -- ['C'] = 'close_all_subnodes',
        ["z"] = "close_all_nodes",
        --["Z"] = "expand_all_nodes",
        ["a"] = {
          "add",
          -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
          -- some commands may take optional config options, see `:h neo-tree-mappings` for details
          config = {
            show_path = "none" -- "none", "relative", "absolute"
          }
        },
        ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
        ["d"] = "delete",
        ["r"] = "rename",
        ["y"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
        -- ["c"] = {
        --  "copy",
        --  config = {
        --    show_path = "none" -- "none", "relative", "absolute"
        --  }
        --}
        ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
        ["q"] = "close_window",
        ["R"] = "refresh",
        ["?"] = "show_help",
        ["<"] = "prev_source",
        [">"] = "next_source",
        ["i"] = "show_file_details",
      }
})

require("bufferline").setup{}

require("gitsigns").setup()

require("telescope").setup({
	pickers = {
		buffers = {
			sort_lastused = true,
		},
	},
})

vim.g.symbols_outline = {
	symbol_blacklist = { "Variable" },
}

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"c",
		"cpp",
		"cuda",
		"go",
		"haskell",
		"javascript",
		"lua",
		"ocaml",
		"python",
		"rust",
		"typescript",
		"vim",
		"yaml",
	},
    sync_install = true,
    auto_install = false,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
})

vim.o.winborder = 'rounded'

---------------------------------------------------------------------------------------------------

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require("cmp")

cmp.setup({
	enabled = function()
        return vim.api.nvim_get_option_value("buftype", {buf = 0 }) ~= "prompt" or require("cmp_dap").is_dap_buffer()
	end,
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = {
			i = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
		},
		["<C-p>"] = {
			i = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
		},
		["<C-y>"] = {
			i = cmp.mapping.confirm({ select = false }),
		},
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.close(),
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<Tab>"] = cmp.mapping(function(fallback)
            local luasnip = require("luasnip")
			if luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
            elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			local luasnip = require("luasnip")
			if luasnip.jumpable(-1) then
            	luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "dap" },
	},
	sorting = {
		comparators = {
			cmp.config.compare.locality,
			cmp.config.compare.recently_used,
			-- require("clangd_extensions.cmp_scores"),
			cmp.config.compare.score,
			cmp.config.compare.offset,
			cmp.config.compare.order,
		},
	},
	formatting = {
		format = function(entry, vim_item)
			vim_item.abbr = string.sub(vim_item.abbr, 1, 50)
			-- Kind icons
			-- vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
			return vim_item
		end,
	},
	window = {
		completion = {
			border = "rounded",
		},
		documentation = {
			border = "rounded",
		},
	},
	experimental = {
		-- ghost_text = true,
	},
})

cmp.setup.filetype("txt", {
  enabled = false,
})

-- LSP configurations
vim.lsp.config['clangd'] = {
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp' },
    root_markers = { 'compile_commands.json', '.git' },
}
vim.lsp.enable('clangd')


local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
vim.lsp.config['luals'] = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
        path = runtime_path,
      },
      diagnostics = {
          globals = { 'vim' },
      },
      workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
      },
      -- For fuck's sake!
      telemetry = {
          enable = false,
      },
    }
  }
}
vim.lsp.enable('luals')

vim.lsp.config['pyright'] = {
    cmd = { 'pyright-langserver', '--stdio' },
    filetypes = { 'python' },
    root_markers = { 'setup.py', 'pyproject.toml', '.git' },
}
vim.lsp.enable('pyright')

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      vim.keymap.del('n', 'K', { buffer = args.buf })
      vim.keymap.set('n', 'k', function() vim.lsp.buf.hover() end)
      vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end)
      vim.keymap.set('n', 'gr', function() vim.lsp.buf.references() end)
      vim.keymap.set('i', '<C-p>', function() vim.lsp.buf.signature_help() end)
      vim.keymap.set('n', '<space>e', function() vim.diagnostic.open_float() end)
      vim.keymap.set('n', ']d', function() vim.diagnostic.jump({count = 1}) end)
      vim.keymap.set('n', '[d', function() vim.diagnostic.jump({count = -1}) end)
      vim.keymap.set('n', ']e', function() vim.diagnostic.jump({count = 1, severity = vim.diagnostic.severity.ERROR}) end)
      vim.keymap.set('n', '[e', function() vim.diagnostic.jump({count = -1, severity = vim.diagnostic.severity.ERROR}) end)
  end,
})

vim.diagnostic.config({ virtual_lines = false, virtual_text = true, underline = false })
