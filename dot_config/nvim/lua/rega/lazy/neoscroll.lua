return {
    "karb94/neoscroll.nvim",
    config = function()
        local neoscroll = require("neoscroll")

        neoscroll.setup({
            mappings = {},
            easing = "quadratic",
            post_hook = function(info)
                if info == "center-cursor" then
                    vim.cmd("normal! zz")
                end
            end,
        })

        vim.keymap.set("n", "<C-d>", function()
            neoscroll.ctrl_d({ duration = 250, info = "center-cursor" })
        end, { desc = "Smooth scroll down and center cursor" })
        vim.keymap.set("n", "<C-u>", function()
            neoscroll.ctrl_u({ duration = 250, info = "center-cursor" })
        end, { desc = "Smooth scroll up and center cursor" })
        vim.keymap.set("n", "<C-f>", function()
            neoscroll.ctrl_f({ duration = 450 })
        end, { desc = "Smooth scroll down one page" })
        vim.keymap.set("n", "<C-b>", function()
            neoscroll.ctrl_b({ duration = 450 })
        end, { desc = "Smooth scroll up one page" })
        vim.keymap.set("n", "<C-e>", function()
            neoscroll.scroll(0.1, { move_cursor = false, duration = 100 })
        end, { desc = "Smooth scroll down one line" })
        vim.keymap.set("n", "<C-y>", function()
            neoscroll.scroll(-0.1, { move_cursor = false, duration = 100 })
        end, { desc = "Smooth scroll up one line" })
        vim.keymap.set("n", "zt", function()
            neoscroll.zt({ half_win_duration = 250 })
        end, { desc = "Smoothly move cursor line to top" })
        vim.keymap.set("n", "zz", function()
            neoscroll.zz({ half_win_duration = 250 })
        end, { desc = "Smoothly center cursor line" })
        vim.keymap.set("n", "zb", function()
            neoscroll.zb({ half_win_duration = 250 })
        end, { desc = "Smoothly move cursor line to bottom" })
    end,
}
