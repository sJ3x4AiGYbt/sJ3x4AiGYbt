#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
echo "==> OS found : $OS"

# first: check sudo (sudo -v or su - && usermod -aG sudo $USER && exit) and check git (git --version or sudo apt update && sudo apt install -y git)

# --- git ---
if [[ -f "$HOME/.gitconfig" ]] && ! cmp -s "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"; then
    backup="$HOME/.gitconfig.bak.$(date +%Y%m%d-%H%M%S)"
    echo "==> ~/.gitconfig differs from the dotfiles one, backing it up to $backup"
    cp "$HOME/.gitconfig" "$backup"
fi
cp "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
echo "==> ~/.gitconfig installed (remember to check the email address inside)"

# --- soft ---
if [[ "$OS" == "Darwin" ]]; then
    load_brew() {
        local b
        for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
            if [[ -x "$b" ]]; then
                eval "$("$b" shellenv)"
                return 0
            fi
        done
        return 1
    }

    if ! command -v brew &>/dev/null && ! load_brew; then
        echo "==> homebrew isn't installed"
        read -r -p "install it now ? [y/N] " reply
        if [[ "$reply" =~ ^[Yy]$ ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            load_brew || { echo "==> brew installed but not found, open a new terminal and run the script again"; exit 1; }
        else
            echo "==> install Homebrew manually then run the script again : https://brew.sh"
            exit 1
        fi
    fi

    if ! grep -qF "brew shellenv" "$HOME/.zprofile" 2>/dev/null; then
        echo "eval \"\$($(command -v brew) shellenv)\"" >> "$HOME/.zprofile"
        echo "==> brew shellenv added to ~/.zprofile"
    fi

    echo "==> installing tools + apps with Brewfile..."
    if ! brew bundle --verbose --file="$DOTFILES_DIR/Brewfile"; then
        echo "==> WARNING: some Brewfile entries failed (see above), continuing"
    fi

elif [[ "$OS" == "Linux" ]]; then
    echo "==> installing tools with apt..."
    sudo apt update
    xargs -a "$DOTFILES_DIR/packages-linux-apt.txt" sudo apt install -y

    if ! command -v docker &>/dev/null; then
        echo "==> installing Docker Engine (official repo)..."
        sudo install -m 0755 -d /etc/apt/keyrings
        . /etc/os-release
        curl -fsSL "https://download.docker.com/linux/${ID}/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    else
        echo "==> docker already installed ($(docker --version))"
    fi

    sudo usermod -aG docker "$USER"
    echo "==> added to the 'docker' group (log back in or run 'newgrp docker')"
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
ALIAS_DIR="$HOME/.config/dotfiles/aliases"
mkdir -p "$ALIAS_DIR"
cp "$DOTFILES_DIR"/aliases/*.sh "$ALIAS_DIR"/
echo "==> alias files copied to $ALIAS_DIR"

read -r -d '' ALIAS_BLOCK << EOF || true
# --- Alias dotfiles (add by install.sh) ---
if [ -n "\$ZSH_VERSION" ]; then
    PROMPT=\$'\n╭─ %D{%d/%m %H:%M} · %n'"\${SSH_CONNECTION:+@%m}"\$' · %~\n╰─> '
elif [ -n "\$BASH_VERSION" ]; then
    PS1='\n╭─ \D{%d/%m %H:%M} · \u'"\${SSH_CONNECTION:+@\h}"' · \w\n╰─> '
fi
[ -f "$ALIAS_DIR/common.sh" ] && source "$ALIAS_DIR/common.sh"
case "\$(uname -s)" in
    Darwin) [ -f "$ALIAS_DIR/mac.sh" ]   && source "$ALIAS_DIR/mac.sh" ;;
    Linux)  [ -f "$ALIAS_DIR/linux.sh" ] && source "$ALIAS_DIR/linux.sh" ;;
esac
# --- end Alias dotfiles ---
EOF

for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [[ "$OS" == "Darwin" && "$rc" == *bashrc && ! -f "$rc" ]]; then
        continue
    fi
    touch "$rc"
    tmp="$(mktemp)"
    awk '
        /# --- Alias dotfiles \(add by install.sh\) ---/ { skip = 1; next }
        skip == 1 { if ($0 == "esac") skip = 2; next }
        skip == 2 { skip = 0; if ($0 ~ /# --- end Alias dotfiles ---/) next }
        { print }
    ' "$rc" > "$tmp"
    cat "$tmp" > "$rc"
    rm -f "$tmp"

    printf '%s\n' "$ALIAS_BLOCK" >> "$rc"
    echo "==> alias block (re)written in $rc"
done

echo
echo '==> finished. restart shell or run `source ~/.zshrc`.'