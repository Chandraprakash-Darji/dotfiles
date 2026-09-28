return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    config = function()
        require("nvim-treesitter").setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        local group = vim.api.nvim_create_augroup("RegaTreesitter", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                if lang then
                    pcall(vim.treesitter.start, args.buf, lang)
                end
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "TSUpdate",
            callback = function()
                require("nvim-treesitter.parsers").templ = {
                    install_info = {
                        url = "https://github.com/vrischmann/tree-sitter-templ.git",
                        files = { "src/parser.c", "src/scanner.c" },
                        branch = "master",
                    },
                }
            end,
        })

        vim.treesitter.language.register("templ", "templ")
    end
}
