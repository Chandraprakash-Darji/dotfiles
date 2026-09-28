# Neovim Keymaps Cheatsheet

Custom mappings configured by this Neovim setup. Plugin-specific mappings below
are available after the corresponding plugin loads; this does not list every
default mapping built into Neovim or each plugin.

## Reading this guide

- **Leader** is `Space`. For example, `<Space>pf` means press Space, then `p`,
  then `f`.
- **Normal**, **Visual**, **Insert**, and **Select** refer to Neovim modes.
- `Ctrl-x` means hold Control while pressing `x`.
- The mappings are mostly Normal-mode mappings unless another mode is shown.
- Open this cheatsheet from Neovim with **`<Space>fk`**.
- For Flash jump, press `s`, type the target text, then press the highlighted
  label shown at the destination.

## Command-line save and quit aliases

These accept a leading capital letter as a typing convenience. Add `!` to force
the corresponding lowercase command when Neovim prompts about unsaved changes.

| Command | Same as |
| --- | --- |
| `:Q` | `:q` |
| `:Qa` / `:Qall` | `:qa` / `:qall` |
| `:W` | `:w` |
| `:Wa` / `:Wall` | `:wa` / `:wall` |
| `:Wq` / `:Qw` | `:wq` |
| `:Wqa` / `:Wqall` | `:wqa` / `:wqall` |

## Navigation and editing

| Mode | Keys | Action |
| --- | --- | --- |
| Normal | `<Space>pv` | Open the netrw file browser (`:Ex`). |
| Normal, Visual, Operator-pending | `s` | Flash jump: type a word or substring, then press the destination label. |
| Visual | `J` / `K` | Move the selected line(s) down / up and reselect them. |
| Normal | `J` | Join the current line with the next, keeping the cursor position. |
| Normal | `Ctrl-d` / `Ctrl-u` | Smoothly scroll down / up by half a page and center the cursor. |
| Normal | `Ctrl-f` / `Ctrl-b` | Smoothly scroll down / up by one page. |
| Normal | `Ctrl-e` / `Ctrl-y` | Smoothly scroll down / up by one line without moving the cursor. |
| Normal | `n` / `N` | Go to the next / previous search match and center it. |
| Normal | `Ctrl-k` / `Ctrl-j` | Next / previous item in the quickfix list. |
| Normal | `<Space>k` / `<Space>j` | Next / previous item in the location list. |
| Normal | `Q` | Disabled. |
| Insert | `Ctrl-c` | Leave Insert mode (same as Escape). |

## Clipboard and text changes

| Mode | Keys | Action |
| --- | --- | --- |
| Visual | `<Space>p` | Replace the selection with the unnamed register without yanking the selection. |
| Normal, Visual | `<Space>y` | Yank to the system clipboard. |
| Normal | `<Space>Y` | Yank the whole line to the system clipboard. |
| Normal, Visual | `y` | Regular yanks use the system clipboard (`unnamedplus`), which macOS can sync through Universal Clipboard. |
| Normal | `yp` | Copy the current file's project-relative path to the clipboard and unnamed register. |
| Normal, Visual | `<Space>d` | Delete to the black-hole register; preserve other registers. |
| Normal | `<Space>s` | Start a global substitution for the word under the cursor in the current file. The command is case-insensitive; edit the replacement on the command line. |
| Normal | `<Space>x` | Run `chmod +x` on the current file. |
| Normal | `<Space>ee` | Insert a Go `if err != nil { return err }` block. |
| Normal | `<Space>mr` | Start the Cellular Automaton “make it rain” animation. |

## Files, search, and Git

| Mode | Keys | Action |
| --- | --- | --- |
| Normal | `<Space><Space>` | Telescope: recent files in the current project, newest first. |
| Normal | `<Space>bl` | Telescope: list open buffers and switch to the selected buffer. |
| Normal | `<Space>pf` | Telescope: search all files in the current project. |
| Normal | `<Space>w` | Save the current buffer. |
| Normal | `<Space>bd` | Close the current buffer; modified buffers still prompt before closing. |
| Normal | `<Space>bn` / `<Space>bp` | Go to the next / previous buffer. |
| Normal | `Ctrl-p` | Telescope: browse Git-tracked files. |
| Normal | `<Space>sg` | Telescope: search file contents across the project (live grep). |
| Normal | `<Space>pws` | Telescope: search for the word under the cursor. |
| Normal | `<Space>pWs` | Telescope: search for the WORD under the cursor. |
| Normal | `<Space>ps` | Telescope: prompt for text to grep. |
| Normal | `<Space>vh` | Telescope: search Neovim help tags. |
| Normal | `<Space>gs` | Open the Fugitive Git status buffer. |
| Normal | `<Space>lg` | Open lazygit in a new terminal tab; press `q` in lazygit to return to Neovim. |
| Normal | `<Space>gf` | Telescope: view Git commit history for the current file. |
| LazyGit Files view | `g` | Generate an OpenCode commit subject from staged changes and copy it; paste and review before committing. |
| Normal, Fugitive buffer | `<Space>p` | Push the current Git branch. |
| Normal, Fugitive buffer | `<Space>P` | Pull with rebase. |
| Normal, Fugitive buffer | `<Space>t` | Begin `git push -u origin`; finish by entering the branch name. |
| Normal | `gu` / `gh` | In a diff, get changes from the other side (`//2` / `//3`). |

## LSP and diagnostics

These mappings are added when an LSP attaches to the current buffer.

| Mode | Keys | Action |
| --- | --- | --- |
| Normal | `gd` | Go to definition. |
| Normal | `K` | Show hover documentation. This replaces the regular `K` mapping in LSP buffers. |
| Normal | `<Space>f` | Format the current buffer with the LSP. |
| Normal | `<Space>vws` | Search workspace symbols. |
| Normal | `<Space>vd` | Show diagnostic details in a float. |
| Normal | `<Space>vca` | Show code actions. |
| Normal | `<Space>vrr` | Find references. |
| Normal | `<Space>vrn` | Rename the symbol. |
| Normal | `<Space>rt` | Toggle inline reference counts next to symbols. Requires an attached LSP with reference support. |
| Normal | `<Space>ru` | Refresh reference counts in the current buffer. |
| Insert | `Ctrl-h` | Show LSP signature help. |
| Normal | `[d` / `]d` | Next / previous diagnostic, respectively, in this config. |

## Tests, documentation, and layout

| Mode | Keys | Action |
| --- | --- | --- |
| Normal | `<Space>tc` | Neotest: run the nearest test. |
| Normal | `<Space>tf` | Neotest: run tests in the current file. |
| Normal | `<Space>nf` | Generate a function documentation comment with Neogen. |
| Normal | `<Space>nt` | Generate a type documentation comment with Neogen. |
| Normal | `<Space>mt` | Toggle rendered Markdown view in a Markdown buffer. |
| Normal | `<Space>tt` | Toggle the Trouble list. |
| Normal | `[t` / `]t` | Go to the next / previous Trouble item. |
| Normal | `<Space>u` | Toggle UndoTree. |
| Normal | `<Space>zz` | Toggle Zen mode at width 90, with line numbers. |
| Normal | `<Space>zZ` | Toggle Zen mode at width 80, without line numbers. |

## Terminal and package scripts

| Mode | Keys | Action |
| --- | --- | --- |
| Normal | `<Space>tx` | Enter any shell command and run it in a bottom terminal; the terminal closes when the command exits. |
| Normal | `<Space>tr` | Telescope search: choose and run a script from the Git project root's `package.json`. |
| Normal | `<Space>tp` | Telescope search: choose and run a script from the nearest `package.json` above the current file. In a monorepo, this selects that package's scripts. |

## Harpoon

| Mode | Keys | Action |
| --- | --- | --- |
| Normal | `<Space>a` | Add the current file to the Harpoon list. |
| Normal | `Ctrl-e` | Toggle the Harpoon quick menu. |
| Normal | `Ctrl-h` / `Ctrl-t` / `Ctrl-n` / `Ctrl-s` | Jump to Harpoon slots 1 / 2 / 3 / 4. |

## Completion and snippets

| Mode | Keys | Action |
| --- | --- | --- |
| Insert, completion menu | `Ctrl-p` / `Ctrl-n` | Select the previous / next completion item. |
| Insert, completion menu | `Ctrl-y` | Confirm the selected completion. |
| Insert | `Ctrl-Space` | Open the completion menu. |
| Insert | `Ctrl-s`, then `e` | Expand the current snippet. |
| Insert, Select | `Ctrl-s`, then `;` / `,` | Jump to the next / previous snippet field. |
| Insert, Select | `Ctrl-e` | Choose the next snippet choice, when a choice is active. |

## Project and session helpers

| Mode | Keys | Action |
| --- | --- | --- |
| Normal | `Ctrl-f` | Open a new tmux window running `tmux-sessionizer`. |
| Normal | `<Space>fk` | Open this cheatsheet. |
| Normal | `<Space>vpp` | Open the legacy Packer config at `lua/rega/packer.lua`. |

## Notes about unavailable or stale mappings

- The `<Space>apm` mapping is commented out in the config, so it is not active.
- `<Space>sg` shares the `<Space>s` prefix with the substitution mapping. Type
  the full `<Space>sg` sequence promptly to start live grep.
- `<Space>fk` shares the `<Space>f` prefix with LSP formatting. Press the full
  sequence promptly; if you wait for the mapping timeout after `<Space>f`, the
  format mapping may run.
