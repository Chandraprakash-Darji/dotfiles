
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Save current buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close current buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Go to next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Go to previous buffer" })

vim.keymap.set("n", "yp", function()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
        vim.notify("Current buffer has no file path", vim.log.levels.WARN)
        return
    end

    file = vim.fn.fnamemodify(file, ":p")
    local root = vim.fs.root(file, { ".git" }) or vim.fn.getcwd()
    local relative_path = vim.fs.relpath(root, file)
    if not relative_path then
        vim.notify("Could not make the file path relative to the project", vim.log.levels.ERROR)
        return
    end

    vim.fn.setreg("+", relative_path)
    vim.fn.setreg('"', relative_path)
    vim.notify("Copied project-relative path: " .. relative_path)
end, { desc = "Yank current file path relative to project" })

local command_aliases = {
    Q = "q",
    Qa = "qa",
    Qall = "qall",
    Qw = "wq",
    W = "w",
    Wa = "wa",
    Wall = "wall",
    Wq = "wq",
    Wqa = "wqa",
    Wqall = "wqall",
}

local function create_command_alias(alias, target)
    vim.api.nvim_create_user_command(alias, function(opts)
        local command = target .. (opts.bang and "!" or "")
        if opts.args ~= "" then
            command = command .. " " .. opts.args
        end
        vim.cmd(command)
    end, {
        bang = true,
        nargs = "*",
        desc = "Alias for :" .. target,
    })
end

for alias, target in pairs(command_aliases) do
    create_command_alias(alias, target)
end

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>fk", function()
    local cheatsheet = vim.fn.stdpath("config") .. "/KEYMAPS.md"
    vim.cmd("edit " .. vim.fn.fnameescape(cheatsheet))
end, { desc = "Open keymaps cheatsheet" })

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set(
    "n",
    "<leader>ee",
    "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)

vim.keymap.set("n", "<leader>vpp", function()
    local packer_config = vim.fn.stdpath("config") .. "/lua/rega/packer.lua"
    vim.cmd("edit " .. vim.fn.fnameescape(packer_config))
end, { desc = "Open legacy Packer config" })
vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");
