local M = {
	active = {},
	inactive = {},
}

M.active[1] = {
	{
		provider = "  ",
		hl = {},
	},
	{
		provider = "file_info",
		hl = {
			fg = "white",
			style = "bold",
		},
	},
	{
		provider = "position",
		left_sep = " ",
		right_sep = "   ",
	},
	{
		provider = "lsp_client_names",
		-- right_sep = {
		--     str = ' ',
		--     hl = {
		--         fg = 'NONE',
		--         bg = 'black'
		--     }
		-- }
	},
	{
		provider = "diagnostic_errors",
		hl = { fg = "red" },
	},
	{
		provider = "diagnostic_warnings",
		hl = { fg = "yellow" },
	},
	{
		provider = "diagnostic_hints",
		hl = { fg = "cyan" },
	},
	{
		provider = "diagnostic_info",
		hl = { fg = "skyblue" },
	},
}

M.active[2] = {
	{
		provider = "git_branch",
		hl = {
			fg = "white",
			bg = "black",
			style = "bold",
		},
		right_sep = {
			str = "  ",
			hl = {
				fg = "NONE",
				bg = "black",
			},
		},
	},
	{
		provider = "line_percentage",
		hl = {
			style = "bold",
		},
		left_sep = "  ",
		right_sep = " ",
	},
}

M.inactive = vim.deepcopy(M.active)
M.inactive[1][2]["hl"]["style"] = "NONE"

return M
