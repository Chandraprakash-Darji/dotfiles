if set -q SSH_CONNECTION
    set -gx EDITOR vim
else
    set -gx EDITOR nvim
end

set -gx TERM xterm-256color
set -U fish_greeting ""

# Java JDK 8 (Zulu)
set -gx JAVA_8_HOME /Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home
set -gx JAVA_HOME $JAVA_8_HOME
fish_add_path -g "$JAVA_HOME/bin"

# Helper to switch Java versions: java8 / java17
function java8
    set -gx JAVA_HOME $JAVA_8_HOME
    fish_add_path -g "$JAVA_HOME/bin"
    echo "Switched to JDK 8: $JAVA_HOME"
end

function java17
    set -gx JAVA_HOME /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
    fish_add_path -g "$JAVA_HOME/bin"
    echo "Switched to JDK 17: $JAVA_HOME"
end

fish_add_path -g "$HOME/.local/bin"
fish_add_path -g "$HOME/go/bin"
fish_add_path -g "$HOME/./antigravity/bin"
fish_add_path -g "$HOME/.antigravity/antigravity/bin"
fish_add_path -g /opt/homebrew/opt/postgresql@18/bin
fish_add_path -g /opt/homebrew/opt/node@24/bin
fish_add_path -g "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fish_add_path -g /opt/homebrew/bin

set -gx PNPM_HOME "$HOME/Library/pnpm"
fish_add_path -g "$PNPM_HOME"

set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path -g "$BUN_INSTALL/bin"

alias code="code"
alias c="clear"
alias e="exit"
alias g="git"
alias ela="eza -a --group-directories-first --icons -l"
alias n="nvim"
alias t="tmux"
alias b="bun"
alias bd="bun dev"
alias p="pnpm"
alias pd="pnpm dev"
alias ga="git add ."
alias gs="git status -s"
alias lg="lazygit"
alias gz="git cz"
alias yz="yazi"
alias y="yazi"
alias oc="opencode"
alias oc2="opencode2"

function tn
    tmux new -s $argv[1]
end

function gc
    git commit -m (string join " " $argv)
end

function nf
    set -l file (fzf)
    test -n "$file"; and nvim "$file"
end

function fish_title
    set -l dir (string replace -r "^$HOME" "~" "$PWD")

    if test "$dir" = "~"; or test "$dir" = /
        echo "$dir"
        return
    end

    set -l current (basename "$dir")
    set -l parent (basename (dirname "$dir"))

    if test -z "$parent"; or test "$parent" = /
        echo "$current"
    else
        echo "$parent/$current"
    end
end

if status is-interactive
    bind \cf 'commandline -r tmux-sessionizer; commandline -f execute'

    if command -q starship
        starship init fish | source
    end

    if command -q zoxide
        zoxide init fish | source
    end
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :


# Added by Antigravity CLI installer
set -gx PATH "/Users/rega/.local/bin" $PATH
