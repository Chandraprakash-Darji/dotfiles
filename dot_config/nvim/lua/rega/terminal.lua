local M = {}

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO)
end

local function current_directory()
    local file = vim.api.nvim_buf_get_name(0)
    if file ~= "" then
        return vim.fs.dirname(vim.fn.fnamemodify(file, ":p"))
    end
    return vim.fn.getcwd(0, 0)
end

local function package_json(directory)
    local path = directory .. "/package.json"
    if vim.fn.filereadable(path) ~= 1 then
        notify("No package.json found at " .. path, vim.log.levels.WARN)
        return
    end

    local content = table.concat(vim.fn.readfile(path), "\n")
    local ok, data = pcall(vim.json.decode, content)
    if not ok or type(data) ~= "table" then
        notify("Could not parse " .. path, vim.log.levels.ERROR)
        return
    end
    return data, path
end

local function package_manager(package, package_directory)
    local declared = type(package.packageManager) == "string"
        and package.packageManager:match("^([^@]+)")
    if declared == "npm" or declared == "pnpm" or declared == "yarn" or declared == "bun" then
        return declared
    end

    local directory = package_directory
    while directory do
        if vim.fn.filereadable(directory .. "/bun.lock") == 1
            or vim.fn.filereadable(directory .. "/bun.lockb") == 1 then
            return "bun"
        elseif vim.fn.filereadable(directory .. "/pnpm-lock.yaml") == 1 then
            return "pnpm"
        elseif vim.fn.filereadable(directory .. "/yarn.lock") == 1 then
            return "yarn"
        elseif vim.fn.filereadable(directory .. "/package-lock.json") == 1 then
            return "npm"
        end

        local parent = vim.fs.dirname(directory)
        if parent == directory then
            break
        end
        directory = parent
    end
    return "npm"
end

function M.run_command(command, cwd)
    if type(command) == "string" then
        command = vim.trim(command)
        if command == "" then
            return
        end
    elseif type(command) == "table" then
        if #command == 0 then
            return
        end
        for _, argument in ipairs(command) do
            if type(argument) ~= "string" then
                notify("Terminal command arguments must be strings", vim.log.levels.ERROR)
                return
            end
        end
    else
        notify("Terminal command must be a string or argument list", vim.log.levels.ERROR)
        return
    end

    vim.cmd("botright 12new")
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_get_current_buf()
    local job = vim.fn.termopen(command, {
        cwd = cwd or vim.fn.getcwd(0, 0),
        on_exit = function(_, code)
            vim.schedule(function()
                if vim.api.nvim_win_is_valid(win)
                    and vim.api.nvim_win_get_buf(win) == buf then
                    vim.api.nvim_win_close(win, true)
                end
                if vim.api.nvim_buf_is_valid(buf) then
                    pcall(vim.api.nvim_buf_delete, buf, { force = true })
                end
                notify(("Command finished (exit %d)"):format(code))
            end)
        end,
    })

    if job <= 0 then
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
        notify("Could not start terminal command", vim.log.levels.ERROR)
        return
    end

    vim.cmd.startinsert()
end

local function choose_script(directory, label)
    local package, path = package_json(directory)
    if not package then
        return
    end

    local scripts = package.scripts
    if type(scripts) ~= "table" then
        notify("No scripts are defined in " .. path, vim.log.levels.WARN)
        return
    end

    local choices = {}
    for name, command in pairs(scripts) do
        if type(name) == "string" and type(command) == "string" then
            table.insert(choices, { name = name, command = command })
        end
    end
    table.sort(choices, function(a, b)
        return a.name < b.name
    end)

    if #choices == 0 then
        notify("No scripts are defined in " .. path, vim.log.levels.WARN)
        return
    end

    local ok, err = pcall(function()
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local telescope_config = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        pickers.new({}, {
            prompt_title = label .. " package scripts (type to filter)",
            finder = finders.new_table({
                results = choices,
                entry_maker = function(choice)
                    local display = ("%s  —  %s"):format(choice.name, choice.command)
                    return {
                        value = choice,
                        display = display,
                        ordinal = choice.name .. " " .. choice.command,
                    }
                end,
            }),
            sorter = telescope_config.generic_sorter({}),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    if not selection then
                        return
                    end
                    local manager = package_manager(package, directory)
                    M.run_command({ manager, "run", selection.value.name }, directory)
                end)
                return true
            end,
        }):find()
    end)

    if not ok then
        notify("Could not open package script picker: " .. tostring(err), vim.log.levels.ERROR)
    end
end

local function project_root()
    local directory = current_directory()
    return vim.fs.root(directory, { ".git" }) or vim.fn.getcwd(0, 0)
end

vim.keymap.set("n", "<leader>tx", function()
    vim.ui.input({ prompt = "Run command: " }, function(command)
        if command then
            M.run_command(command, vim.fn.getcwd(0, 0))
        end
    end)
end, { desc = "Run a shell command in a terminal" })

vim.keymap.set("n", "<leader>tr", function()
    choose_script(project_root(), "Project root")
end, { desc = "Choose a script from the project root package.json" })

vim.keymap.set("n", "<leader>tp", function()
    local file = vim.api.nvim_buf_get_name(0)
    local path = file ~= "" and vim.fn.fnamemodify(file, ":p") or current_directory()
    local directory = vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
    local package_file = vim.fs.find("package.json", { path = directory, upward = true })[1]
    if not package_file then
        notify("No package.json found above " .. directory, vim.log.levels.WARN)
        return
    end
    choose_script(vim.fs.dirname(package_file), "Nearest package")
end, { desc = "Choose a script from the nearest package.json" })

return M
