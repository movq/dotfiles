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
vim.o.exrc = true

vim.g.rust_recommended_style = false

vim.cmd("autocmd FileType text lua require 'cmp'.setup.buffer { sources = {} }")
vim.cmd("autocmd FileType yaml setlocal indentkeys-=0#")


vim.cmd.colorscheme 'retrobox'

require("auto-save").setup()

vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
require("auto-session").setup({
    suppressed_dirs = { "~/", "~/src", "~/data", "~/downloads", "/"},
})

require("telescope").setup({
    defaults = {
        path_display = {"truncate"},
    },
	pickers = {
		buffers = {
			sort_lastused = true,
		},
	},
})

vim.g.symbols_outline = {
	symbol_blacklist = { "Variable" },
}

vim.o.winborder = 'rounded'

---------------------------------------------------------------------------------------------------

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require("cmp")

cmp.setup({
	enabled = function()
        return vim.api.nvim_get_option_value("buftype", {buf = 0 }) ~= "prompt"
	end,
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
		["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<Tab>"] = cmp.mapping(function(fallback)
            if has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
            fallback()
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "copilot" },
		{ name = "nvim_lsp" },
		{ name = "buffer" },
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
    cmd = { 'clangd', '--background-index', '--query-driver=\'/usr/bin/\'' },
    filetypes = { 'c', 'cpp', 'cuda' },
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

vim.lsp.config['gopls'] = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
    root_markers = { 'go.mod', 'go.work', '.git' },
}
vim.lsp.enable('gopls')

vim.lsp.config['rust-analyzer'] = {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
    settings = {
        ["rust-analyzer"] = {
            diagnostics = {
                enable = true,
                experimental = {
                    enable = true
                }
            }
        }
    }
}
vim.lsp.enable('rust-analyzer')

vim.lsp.config['zls'] = {
    cmd = { 'zls' },
    filetypes = { 'zig' },
    root_markers = { 'build.zig', '.git' },
}
vim.lsp.enable('zls')

vim.lsp.config['ty'] = {
    cmd = { 'ty', 'server' },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', '.git' },
}
vim.lsp.enable('ty')

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      -- vim.keymap.del('n', 'K', { buffer = args.buf })
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

-- Trailing whitespace highlighting (hidden on current line)
vim.api.nvim_set_hl(0, 'TrailingWhitespace', { bg = 'LightRed' })

local trailing_ws_state = {}

local function clear_trailing_ws(win)
    if trailing_ws_state[win] then
        for _, id in ipairs(trailing_ws_state[win].matches) do
            pcall(vim.fn.matchdelete, id)
        end
        trailing_ws_state[win] = nil
    end
end

local function should_highlight_trailing_ws(win)
    local buf = vim.api.nvim_win_get_buf(win)
    local bt = vim.api.nvim_get_option_value('buftype', { buf = buf })
    if bt ~= '' then
        return false
    end

    local cfg = vim.api.nvim_win_get_config(win)
    return cfg.relative == ''
end

local function update_trailing_ws()
    local win = vim.api.nvim_get_current_win()
    if not should_highlight_trailing_ws(win) then
        clear_trailing_ws(win)
        return
    end

    local cur_line = vim.fn.line('.')

    if trailing_ws_state[win] and trailing_ws_state[win].line == cur_line then
        return
    end

    clear_trailing_ws(win)

    local matches = {}
    if cur_line > 1 then
        matches[1] = vim.fn.matchadd('TrailingWhitespace', '\\%<' .. cur_line .. 'l\\s\\+$')
    end
    matches[#matches + 1] = vim.fn.matchadd('TrailingWhitespace', '\\%>' .. cur_line .. 'l\\s\\+$')

    trailing_ws_state[win] = { line = cur_line, matches = matches }
end

vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufWinEnter' }, {
    pattern = '*',
    callback = update_trailing_ws,
})

vim.api.nvim_create_autocmd('WinClosed', {
    pattern = '*',
    callback = function(args)
        trailing_ws_state[tonumber(args.match)] = nil
    end,
})
