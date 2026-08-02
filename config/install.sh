#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
echo "==> OS find : $OS"

# --- git ---
if [[ -f "$HOME/.gitconfig" ]]; then
    echo "==> ~/.gitconfig already exist, backing it up to .gitconfig.bak"
    cp "$HOME/.gitconfig" "$HOME/.gitconfig.bak"
fi
cp "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
echo "==> ~/.gitconfig installed (remember to ckeck the email address inside)"

# --- soft ---
if [[ "$OS" == "Darwin" ]]; then
    if ! command -v brew &>/dev/null; then
        echo "==> homebrew isn't installed"
        read -r -p "install it now ? [y/N] " reply
        if [[ "$reply" =~ ^[Yy]$ ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            echo "==> install Homebrew manually then run the script again : https://brew.sh"
            exit 1
        fi
    fi
    echo "==> installing tools + apps with Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"

elif [[ "$OS" == "Linux" ]]; then
    echo "==> installing tools with apt..."
    sudo apt update
    xargs -a "$DOTFILES_DIR/packages-linux-apt.txt" sudo apt install -y

    if command -v docker &>/dev/null; then
        sudo usermod -aG docker "$USER"
        echo "==> add to the 'docker' group (log back in or run 'newgrp docker')"
    fi
fi

# --- rust ---
if command -v rustc &>/dev/null; then
    echo "==> rust already installed ($(rustc --version))"
else
    echo "==> installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# --- alias ---
read -r -d '' ALIAS_BLOCK << EOF || true
 
# --- Alias dotfiles (add by install.sh) ---
[ -f "$DOTFILES_DIR/aliases/common.sh" ] && source "$DOTFILES_DIR/aliases/common.sh"
case "\$(uname -s)" in
    Darwin) [ -f "$DOTFILES_DIR/aliases/mac.sh" ]   && source "$DOTFILES_DIR/aliases/mac.sh" ;;
    Linux)  [ -f "$DOTFILES_DIR/aliases/linux.sh" ] && source "$DOTFILES_DIR/aliases/linux.sh" ;;
esac
EOF
 
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    touch "$rc"
    if grep -qF "alias dotfiles (add by install.sh)" "$rc" 2>/dev/null; then
        echo "==> alias already listed in $rc"
    else
        printf '%s\n' "$ALIAS_BLOCK" >> "$rc"
        echo "==> alias add in $rc"
    fi
done

echo
echo "==> finished. restart shell or run `source ~/.zshrc`."