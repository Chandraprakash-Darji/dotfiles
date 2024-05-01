return {
	-- messages, cmdline and the popupmenu
	{
		"folke/noice.nvim",
		config = function()
			local noice = require("noice")
			local focused = true
			vim.api.nvim_create_autocmd("FocusGained", {
				callback = function()
					focused = true
				end,
			})
			vim.api.nvim_create_autocmd("FocusLost", {
				callback = function()
					focused = false
				end,
			})
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function(event)
					vim.schedule(function()
						require("noice.text.markdown").keys(event.buf)
					end)
				end,
			})

			require("noice").setup({
				presets = {
					lsp_doc_border = true,
				},
				routes = {
					{
						filter = {
							event = "notify",
							find = "No information available",
						},
						opts = { skip = true },
					},
					{
						filter = {
							cond = function()
								return not focused
							end,
						},
						view = "notify_send",
						opts = { stop = false },
					},
				},
				commands = {
					all = {
						-- options for the message history that you get with `:Noice`
						view = "split",
						opts = { enter = true, format = "details" },
						filter = {},
					},
				},
			})
		end,
	},
	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 5000,
		},
	},

	-- animations
	{
		"echasnovski/mini.animate",
		event = "VeryLazy",
		opts = function(_, opts)
			opts.scroll = {
				enable = false,
			}
		end,
	},
	-- buffer line
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
		},
		opts = {
			options = {
				mode = "tabs",
				-- separator_style = "slant",
				show_buffer_close_icons = false,
				show_close_icon = false,
			},
		},
	},
	-- filename
	{
		"b0o/incline.nvim",
		dependencies = { "craftzdog/solarized-osaka.nvim" },
		event = "BufReadPre",
		priority = 1200,
		config = function()
			local colors = require("solarized-osaka.colors").setup()
			require("incline").setup({
				highlight = {
					groups = {
						InclineNormal = { guibg = colors.magenta500, guifg = colors.base04 },
						InclineNormalNC = { guifg = colors.violet500, guibg = colors.base03 },
					},
				},
				window = { margin = { vertical = 0, horizontal = 1 } },
				hide = {
					cursorline = true,
				},
				render = function(props)
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					if vim.bo[props.buf].modified then
						filename = "[+] " .. filename
					end

					local icon, color = require("nvim-web-devicons").get_icon_color(filename)
					return { { icon, guifg = color }, { " " }, { filename } }
				end,
			})
		end,
	},

	-- tabs
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
			{ "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
		},
		opts = {
			options = {
				mode = "tabs",
				-- separator_style = "slant",
				show_buffer_close_icons = false,
				show_close_icon = false,
			},
		},
	},
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		opts = {
			plugins = {
				gitsigns = true,
				tmux = true,
				kitty = { enabled = false, font = "+2" },
			},
		},
		keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
	},

	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		config = function()
			local logo = [[
                                                                                       ..                     .x+=:.
                                                                                     dF                      z`    ^%
    .u    .                                                                    u.   '88bu.                      .   <k
  .d88B :@8c       .u         uL           u                        .    ...ue888b  '*88888bu        .u       .@8Ned8"
 ="8888f8888r   ud8888.   .ue888Nc..    us888u.                .udR88N   888R Y888r   ^"*8888N    ud8888.   .@^%8888"
   4888>'88"  :888'8888. d88E`"888E` .@88 "8888"              <888'888k  888R I888>  beWE "888L :888'8888. x88:  `)8b.
   4888> '    d888 '88%" 888E  888E  9888  9888               9888 'Y"   888R I888>  888E  888E d888 '88%" 8888N=*8888
   4888>      8888.+"    888E  888E  9888  9888               9888       888R I888>  888E  888E 8888.+"     %8"    R88
  .d888L .+   8888L      888E  888E  9888  9888        .      9888      u8888cJ888   888E  888F 8888L        @8Wou 9%
  ^"8888*"    '8888c. .+ 888& .888E  9888  9888      .@8c     ?8888u../  "*888*P"   .888N..888  '8888c. .+ .888888P`
     "Y"       "88888%   *888" 888&  "888*""888"    '%888"     "8888P'     'Y"       `"888*""    "88888%   `   ^"F
                 "YP'     `"   "888E  ^Y"   ^Y'       ^*         "P'                    ""         "YP'
                         .dWi   `88E
                         4888~  J8%
                          ^"===*"`
                          ]]
			logo = string.rep("\n", 8) .. logo .. "\n\n"

			require("dashboard").setup({
				config = {
					header = vim.split(logo, "\n"),
				},
			})
		end,
	},
}
