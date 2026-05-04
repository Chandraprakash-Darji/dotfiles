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
    tmux
    eza
    fzf
    lazygit
    gh
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

install_zsh_plugins() {
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  log "Installing zsh plugins"
  clone_or_pull_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$zsh_custom/plugins/zsh-syntax-highlighting"
  clone_or_pull_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$zsh_custom/plugins/zsh-autosuggestions"

  mkdir -p "$HOME/.zsh"
  clone_or_pull_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$HOME/.zsh/zsh-autosuggestions"
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

Then reload shell:
  exec zsh
EOF
}

main() {
  install_xcode_cli_tools
  install_homebrew
  init_brew_shellenv
  install_brew_packages
  ensure_oh_my_zsh
  install_zsh_plugins
  setup_node_tooling
  setup_bun
  setup_postgresql_path
  setup_pipx_tools
  start_services_hint
}

main "$@"
