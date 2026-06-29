#!/usr/bin/env bash
set -euo pipefail

log() {
    printf "\n[%s] %s\n" "$(date +"%H:%M:%S")" "$*"
}

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

ensure_line_in_file() {
    local line="$1"
    local file="$2"

    touch "$file"
    if ! grep -Fqx "$line" "$file"; then
        printf "%s\n" "$line" >>"$file"
    fi
}

brew_prefix() {
    if [[ -x /opt/homebrew/bin/brew ]]; then
        printf "/opt/homebrew"
    elif [[ -x /usr/local/bin/brew ]]; then
        printf "/usr/local"
    else
        printf ""
    fi
}

install_xcode_cli_tools() {
    if xcode-select -p >/dev/null 2>&1; then
        log "Xcode Command Line Tools already installed"
        return
    fi

    log "Installing Xcode Command Line Tools"
    xcode-select --install || true
    log "Follow the macOS installer prompt, then re-run this script if needed"
}

install_homebrew() {
    if has_cmd brew; then
        log "Homebrew already installed"
        return
    fi

    log "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

init_brew_shellenv() {
    local prefix
    prefix="$(brew_prefix)"

    if [[ -z "$prefix" ]]; then
        return
    fi

    if [[ ":$PATH:" != *":$prefix/bin:"* ]]; then
        export PATH="$prefix/bin:$prefix/sbin:$PATH"
    fi

    eval "$("$prefix/bin/brew" shellenv)"

    ensure_line_in_file "eval \"\$($prefix/bin/brew shellenv)\"" "$HOME/.zprofile"
}

install_brew_packages() {
    local packages=(
        git
        curl
        chezmoi
        fish
        tmux
        eza
        fzf
        zoxide
        lazygit
        gh
        ripgrep
        fd
        bat
        ghq
        starship
        neovim
        pipx
        imagemagick
        pkg-config
        mariadb
        redis
        postgresql@18
        node@24
        oven-sh/bun/bun
        yazi
        ollama
    )

    log "Installing Homebrew packages"
    brew update
    for pkg in "${packages[@]}"; do
        if brew list "$pkg" >/dev/null 2>&1; then
            log "Package already installed: $pkg"
        else
            brew install "$pkg"
        fi
    done
}

install_brew_casks() {
    local casks=(
        ghostty
        kitty
        notunes
        visual-studio-code
        claude-code
        ngrok
        shottr
        obsidian
        lm-studio
        font-fira-code-nerd-font
        kde-mac/kde/kdeconnect
        zen@twilight
        karabiner-elements
        keepingyouawake
        pearcleaner
        tablepro
    )

    log "Installing Homebrew casks"
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" >/dev/null 2>&1; then
            log "Cask already installed: $cask"
        else
            brew install --cask "$cask"
        fi
    done
}

ensure_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log "Oh My Zsh already installed"
        return
    fi

    log "Installing Oh My Zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

clone_or_pull_repo() {
    local repo_url="$1"
    local target_dir="$2"

    if [[ -d "$target_dir/.git" ]]; then
        git -C "$target_dir" pull --ff-only
    else
        rm -rf "$target_dir"
        git clone "$repo_url" "$target_dir"
    fi
}

install_fira_code_iscript_font() {
    local font_source_dir="$HOME/.local/share/fonts-src/FiraCodeiScript"
    local font_target_dir="$HOME/Library/Fonts"
    local font

    log "Installing Fira Code iScript font"
    mkdir -p "$HOME/.local/share/fonts-src" "$font_target_dir"
    clone_or_pull_repo "https://github.com/kencrocken/FiraCodeiScript.git" "$font_source_dir"

    for font in "$font_source_dir"/*.ttf; do
        [[ -e "$font" ]] || continue
        install -m 0644 "$font" "$font_target_dir/"
    done
}

install_zsh_plugins() {
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    log "Installing zsh plugins"
    clone_or_pull_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$zsh_custom/plugins/zsh-syntax-highlighting"
    clone_or_pull_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$zsh_custom/plugins/zsh-autosuggestions"

    mkdir -p "$HOME/.zsh"
    clone_or_pull_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$HOME/.zsh/zsh-autosuggestions"
}

setup_rust_toolchain() {
    if has_cmd cargo && has_cmd rustc; then
        log "Rust toolchain already installed"
    else
        log "Installing Rust toolchain"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi

    if [[ -f "$HOME/.cargo/env" ]]; then
        # Needed so cargo is available to the rest of this script immediately.
        # shellcheck disable=SC1090
        . "$HOME/.cargo/env"
    fi
}

setup_rift() {
    local repo_url="https://github.com/Chandraprakash-Darji/rift"
    local repo_dir

    if ! has_cmd ghq; then
        log "ghq is required to set up Rift"
        return 1
    fi

    log "Fetching Rift source with ghq"
    ghq get "$repo_url"

    repo_dir="$(ghq list -p Chandraprakash-Darji/rift | head -n 1)"
    if [[ -z "$repo_dir" || ! -d "$repo_dir" ]]; then
        log "Unable to locate Rift repo after ghq get"
        return 1
    fi

    setup_rust_toolchain

    log "Installing Rift launch service"
    (
        cd "$repo_dir"
        cargo run --bin rift --release service install
        cargo run --bin rift --release service start
    )

    if has_cmd chezmoi; then
        log "Applying Rift config"
        chezmoi apply "$HOME/.config/rift/config.toml"
    fi
}

setup_node_tooling() {
    local prefix
    prefix="$(brew --prefix)"

    log "Configuring Node.js 24 and Corepack"
    export PATH="$prefix/opt/node@24/bin:$PATH"

    corepack enable pnpm || true
    corepack enable yarn || true

    if has_cmd pnpm; then
        pnpm setup >/dev/null 2>&1 || true
    fi
}

setup_bun() {
    local prefix
    prefix="$(brew --prefix)"

    export PATH="$prefix/opt/node@24/bin:$HOME/.bun/bin:$PATH"
}

setup_postgresql_path() {
    local prefix
    prefix="$(brew --prefix)"

    export PATH="$prefix/opt/postgresql@18/bin:$PATH"
}

setup_pipx_tools() {
    if ! has_cmd pipx; then
        return
    fi

    log "Configuring pipx"
    pipx ensurepath || true

    if ! pipx list | grep -q "package pywal"; then
        pipx install pywal
    else
        log "pywal already installed via pipx"
    fi
}

start_services_hint() {
    cat <<'EOF'

Setup completed.

Shell config is managed by your dotfiles.
If needed, apply them first:
  chezmoi apply

Optional services (start when needed):
  brew services start mariadb redis postgresql@18

Authenticate GitHub CLI when needed:
  gh auth login

Then reload shell:
  exec zsh
EOF
}

main() {
    install_xcode_cli_tools
    install_homebrew
    init_brew_shellenv
    install_brew_packages
    install_brew_casks
    ensure_oh_my_zsh
    install_zsh_plugins
    install_fira_code_iscript_font
    setup_rift
    setup_node_tooling
    setup_bun
    setup_postgresql_path
    setup_pipx_tools
    start_services_hint
}

main "$@"
