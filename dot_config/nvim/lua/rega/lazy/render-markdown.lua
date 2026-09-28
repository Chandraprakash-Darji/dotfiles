return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        { "<leader>mt", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle Markdown rendering" },
    },
    opts = {},
}
