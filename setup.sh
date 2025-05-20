#!/usr/bin/env bash
set -euo pipefail

# ---- 0 · sanity -------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq

# ---- 1 · apt bits -----------------------------------------------------------
apt-get install -y git curl magic-wormhole fd-find

# ---- 2 · ZeroTier (quiet) ---------------------------------------------------
curl -fsSL https://install.zerotier.com | bash

# ---- 3 · Rust toolchain (non-interactive) -----------------------------------
curl -fsSL https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"        # shell in the new cargo

# ---- 4 · Rust apps ----------------------------------------------------------
cargo install --locked bob-nvim

BASH_RC="$HOME/.bashrc"        # or "$HOME/.zshrc" for z shell

if ! grep -q 'bob/nvim-bin' "$BASH_RC"; then
  cat >>"$BASH_RC" <<'EOF'

# Bob-Neovim ─ add nightly/stable wrappers to PATH
if [ -d "$HOME/.local/share/bob/nvim-bin" ]; then
  PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
fi
EOF
fi

# ---- 5 · Atuin (shell history sync) ----------------------------------------
curl -fsSL https://setup.atuin.sh | bash -s -- --yes

# ---- 6 · Drop in my Neovim config ------------------------------------------
NVIM_DIR="$HOME/.config/nvim"
BACKUP_STAMP=$(date +%s)

if [ -e "$NVIM_DIR" ] && [ ! -L "$NVIM_DIR" ]; then
  echo "▶︎ Found an existing nvim config – backing it up to ${NVIM_DIR}.bak.${BACKUP_STAMP}"
  mv "$NVIM_DIR" "${NVIM_DIR}.bak.${BACKUP_STAMP}"
fi

git clone --depth 1 https://github.com/djmango/dotfiles-nvim.git "$NVIM_DIR"
grep -qxF 'export VISUAL="nvim"' ~/.bashrc || {
  printf '\n# default to Neovim\nexport VISUAL="nvim"\nexport EDITOR="nvim"\n' >> ~/.bashrc
}
