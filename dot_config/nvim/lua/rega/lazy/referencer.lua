return {
    "romus204/referencer.nvim",
    config = function()
        require("referencer").setup()

        vim.keymap.set("n", "<leader>rt", "<cmd>ReferencerToggle<CR>", {
            desc = "Toggle inline reference counts",
        })
        vim.keymap.set("n", "<leader>ru", "<cmd>ReferencerUpdate<CR>", {
            desc = "Update inline reference counts",
        })
    end,
}
