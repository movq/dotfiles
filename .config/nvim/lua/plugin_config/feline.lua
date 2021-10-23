local M = {
    active = {},
    inactive = {}
}

M.active[1] = {
    {
        provider = '  ',
        hl = {
        }
    },
    {
        provider = 'file_info',
        hl = {
            fg = 'white',
            style = 'bold'
        },
    },
    {
        provider = 'position',
        left_sep = ' ',
    },
    {
        provider = 'diagnostic_errors',
        hl = { fg = 'red' }
    },
    {
        provider = 'diagnostic_warnings',
        hl = { fg = 'yellow' }
    },
    {
        provider = 'diagnostic_hints',
        hl = { fg = 'cyan' }
    },
    {
        provider = 'diagnostic_info',
        hl = { fg = 'skyblue' }
    },
}

M.active[2] = {
    {
        provider = 'git_branch',
        hl = {
            fg = 'white',
            bg = 'black',
            style = 'bold'
        },
        right_sep = {
            str = '  ',
            hl = {
                fg = 'NONE',
                bg = 'black'
            }
        }
    },
    {
        provider = 'git_diff_added',
        hl = {
            fg = 'green',
            bg = 'black'
        }
    },
    {
        provider = 'git_diff_changed',
        hl = {
            fg = 'orange',
            bg = 'black'
        }
    },
    {
        provider = 'git_diff_removed',
        hl = {
            fg = 'red',
            bg = 'black'
        },
        right_sep = {
            str = ' ',
            hl = {
                fg = 'NONE',
                bg = 'black'
            }
        }
    },
    {
        provider = 'line_percentage',
        hl = {
            style = 'bold'
        },
        left_sep = '  ',
        right_sep = ' '
    },
}

-- M.inactive = M.active

return M
