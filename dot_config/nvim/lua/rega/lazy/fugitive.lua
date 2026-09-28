return {
    "tpope/vim-fugitive",
    config = function() 
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
        vim.keymap.set("n", "<leader>lg", function()
            vim.cmd.tabnew()
            local terminal_window = vim.api.nvim_get_current_win()
            vim.fn.termopen("lazygit", {
                env = { CONFIG_DIR = vim.fn.expand("~/.config/lazygit") },
                on_exit = function()
                    vim.schedule(function()
                        if vim.api.nvim_win_is_valid(terminal_window) then
                            vim.api.nvim_win_close(terminal_window, true)
                        end
                    end)
                end,
            })
            vim.cmd.startinsert()
        end, { desc = "Open lazygit in a new tab" })

        local Rega_Fugitive = vim.api.nvim_create_augroup("Rega_Fugitive", {})

        local autocmd = vim.api.nvim_create_autocmd
        autocmd("BufWinEnter", {
            group = Rega_Fugitive,
            pattern = "*",
            callback = function()
                if vim.bo.ft ~= "fugitive" then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                local opts = {buffer = bufnr, remap = false}
                vim.keymap.set("n", "<leader>p", function()
                    vim.cmd.Git('push')
                end, opts)

                -- rebase always
                vim.keymap.set("n", "<leader>P", function()
                    vim.cmd.Git({'pull',  '--rebase'})
                end, opts)

                -- NOTE: It allows me to easily set the branch i am pushing and any tracking
                -- needed if i did not set the branch up correctly
                vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts);
            end,
        })


        vim.keymap.set("n", "gu", "<cmd>diffget //2<CR>")
        vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>")
    end
}
