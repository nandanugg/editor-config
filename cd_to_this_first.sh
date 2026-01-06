#!/bin/bash

set -euo pipefail

# Detect the package manager and set up installation functions
detect_package_manager() {
  if command -v brew &> /dev/null; then
    PKG_MANAGER="brew"
  elif command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
  elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
  else
    PKG_MANAGER="unknown"
  fi
  echo "🔧 Detected package manager: $PKG_MANAGER"
}

# Install a package using the appropriate package manager
# Usage: install_package <package_name> [apt_name] [pacman_name]
# If apt_name or pacman_name not provided, uses package_name
install_package() {
  local pkg_name="$1"
  local apt_name="${2:-$pkg_name}"
  local pacman_name="${3:-$pkg_name}"

  case "$PKG_MANAGER" in
    brew)
      if ! brew list --formula 2>/dev/null | grep -q "^${pkg_name}$"; then
        echo "📦 Installing $pkg_name via Homebrew..."
        brew install "$pkg_name"
        echo "✅ Installed $pkg_name"
      else
        echo "✅ $pkg_name already installed"
      fi
      ;;
    apt)
      if ! dpkg -l "$apt_name" 2>/dev/null | grep -q "^ii"; then
        echo "📦 Installing $apt_name via APT..."
        sudo apt update -qq
        sudo apt install -y "$apt_name"
        echo "✅ Installed $apt_name"
      else
        echo "✅ $apt_name already installed"
      fi
      ;;
    pacman)
      if ! pacman -Q "$pacman_name" &> /dev/null; then
        echo "📦 Installing $pacman_name via Pacman..."
        sudo pacman -S --noconfirm "$pacman_name"
        echo "✅ Installed $pacman_name"
      else
        echo "✅ $pacman_name already installed"
      fi
      ;;
    *)
      echo "⚠️ Unknown package manager. Please install $pkg_name manually."
      return 1
      ;;
  esac
}

# Check if a package is installed
is_package_installed() {
  local pkg_name="$1"
  local apt_name="${2:-$pkg_name}"
  local pacman_name="${3:-$pkg_name}"

  case "$PKG_MANAGER" in
    brew)
      brew list --formula 2>/dev/null | grep -q "^${pkg_name}$"
      ;;
    apt)
      dpkg -l "$apt_name" 2>/dev/null | grep -q "^ii"
      ;;
    pacman)
      pacman -Q "$pacman_name" &> /dev/null
      ;;
    *)
      command -v "$pkg_name" &> /dev/null
      ;;
  esac
}

# Install Homebrew (macOS only)
install_homebrew() {
  if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "✅ Installed Homebrew"
  else
    echo "✅ Homebrew already installed"
  fi
}

install_antigen() {
  if [ ! -f "$HOME/antigen.zsh" ]; then
    echo "🎨 Installing Antigen..."
    curl -L git.io/antigen > "$HOME/antigen.zsh"
    echo "✅ Installed Antigen to $HOME/antigen.zsh"
  else
    echo "✅ Antigen already installed at $HOME/antigen.zsh"
  fi
}

# Utility function to create a symlink only if necessary
ensure_symlink() {
  local src="$1"
  local dst="$2"
  local name="$3"

  # Check if source exists
  if [ ! -e "$src" ]; then
    # Remove broken symlink if it exists
    if [ -L "$dst" ]; then
      echo "🔄 Removing broken symlink: $dst"
      rm -f "$dst"
    fi
    echo "⚠️ Source not found for $name: $src (skipping)"
    return 0
  fi

  if [ -L "$dst" ]; then
    local current
    current=$(readlink "$dst")
    if [[ "$current" == "$src" ]]; then
      # Verify the symlink target actually exists
      if [ -e "$dst" ]; then
        echo "✅ $name already synced"
        return 0
      else
        echo "🔄 Fixing broken symlink: $dst"
        rm -f "$dst"
      fi
    else
      echo "🔄 Updating symlink: $dst -> $src"
      rm -f "$dst"
    fi
  elif [ -e "$dst" ]; then
    echo "🔄 Removing existing file/dir: $dst"
    rm -rf "$dst"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "✅ Sync $name"
}

# Utility function to create a symlink that requires sudo
ensure_symlink_sudo() {
  local src="$1"
  local dst="$2"
  local name="$3"

  # Check if source exists
  if [ ! -e "$src" ]; then
    # Remove broken symlink if it exists
    if [ -L "$dst" ]; then
      echo "🔄 Removing broken symlink: $dst"
      sudo rm -f "$dst"
    fi
    echo "⚠️ Source not found for $name: $src (skipping)"
    return 0
  fi

  if [ -L "$dst" ]; then
    local current
    current=$(readlink "$dst")
    if [[ "$current" == "$src" ]]; then
      # Verify the symlink target actually exists
      if [ -e "$dst" ]; then
        echo "✅ $name already synced"
        return 0
      else
        echo "🔄 Fixing broken symlink: $dst"
        sudo rm -f "$dst"
      fi
    else
      echo "🔄 Updating symlink: $dst -> $src"
      sudo rm -f "$dst"
    fi
  elif [ -e "$dst" ]; then
    echo "🔄 Backing up existing file: $dst -> ${dst}.backup"
    sudo mv "$dst" "${dst}.backup"
  fi

  sudo mkdir -p "$(dirname "$dst")"
  sudo ln -s "$src" "$dst"
  echo "✅ Sync $name"
}

# Get the appropriate config directory for Ghostty based on OS
get_ghostty_config_path() {
  case "$(uname)" in
    Darwin)
      echo "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
      ;;
    Linux)
      echo "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
      ;;
    *)
      echo "$HOME/.config/ghostty/config"
      ;;
  esac
}

# Detect if running on WSL
is_wsl() {
  if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
    return 0
  elif [[ -n "${WSL_DISTRO_NAME}" ]]; then
    return 0
  else
    return 1
  fi
}

# ============================================================================
# Main Script
# ============================================================================

# Home directory
HOME_DIR="$HOME"

echo "🚀 Starting dotfiles setup..."
echo "📂 Running from: $(pwd)"
echo "🏠 Home directory: $HOME_DIR"
echo "💻 Operating system: $(uname -s)"
if is_wsl; then
  echo "🐧 WSL detected"
fi

# Detect package manager first, then install Homebrew only on macOS if needed
if [[ "$(uname)" == "Darwin" ]]; then
  install_homebrew
fi

# Detect package manager
detect_package_manager

# Install antigen
install_antigen

# Sync dotfiles
echo ""
echo "📋 Syncing dotfiles..."
ensure_symlink "$(pwd)/bin" "$HOME_DIR/bin" "bin"
ensure_symlink "$(pwd)/.gitconfig" "$HOME_DIR/.gitconfig" ".gitconfig"
ensure_symlink "$(pwd)/.vimrc" "$HOME_DIR/.vimrc" ".vimrc"
ensure_symlink "$(pwd)/.netrc" "$HOME_DIR/.netrc" ".netrc"
ensure_symlink "$(pwd)/.zshrc" "$HOME_DIR/.zshrc" ".zshrc"
ensure_symlink "$(pwd)/.gitignore_global" "$HOME_DIR/.gitignore_global" ".gitignore_global"
ensure_symlink "$(pwd)/.tmux.conf.local" "$HOME_DIR/.config/tmux/tmux.conf.local" "tmux.conf.local"

# Ghostty config (OS-aware path)
GHOSTTY_CONFIG_PATH=$(get_ghostty_config_path)
ensure_symlink "$(pwd)/.ghosttyrc" "$GHOSTTY_CONFIG_PATH" ".ghosttyrc"

# WSL-specific configuration
if is_wsl; then
  echo ""
  echo "🐧 Setting up WSL-specific configuration..."
  
  # Symlink wsl.conf to /etc/wsl.conf (requires sudo)
  if [ -f "$(pwd)/wsl.conf" ]; then
    ensure_symlink_sudo "$(pwd)/wsl.conf" "/etc/wsl.conf" "wsl.conf"
    echo "ℹ️  Note: Changes to /etc/wsl.conf require WSL restart to take effect"
    echo "   Run 'wsl.exe --shutdown' from Windows to restart WSL"
  else
    echo "⚠️  wsl.conf not found in $(pwd), skipping /etc/wsl.conf setup"
  fi
  
  echo ""
  echo "ℹ️  For Windows Terminal settings.json, run setup-windows.bat as Administrator"
fi

# Install oh-my-zsh only if not already present
echo ""
echo "🔌 Installing shell plugins..."
OMZ_DIR="$HOME_DIR/.oh-my-zsh"
if [ ! -d "$OMZ_DIR" ]; then
  echo "📦 Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  echo "✅ Installed oh-my-zsh"
else
  echo "✅ oh-my-zsh already installed"
fi

# Install packages
echo ""
echo "🎨 Installing packages..."

# Install essential tools (git, openssh, rsync for Arch)
if [[ "$PKG_MANAGER" == "pacman" ]]; then
  install_package "git" "git" "git"
  install_package "curl" "curl" "curl"
  install_package "openssh" "openssh-client" "openssh"
  install_package "rsync" "rsync" "rsync"
fi

# Install zsh if not present (needed for oh-my-zsh)
if ! command -v zsh &> /dev/null; then
  install_package "zsh" "zsh" "zsh"
fi

# Install tmux
install_package "tmux" "tmux" "tmux"

# Install direnv
install_package "direnv" "direnv" "direnv"

# Install zoxide
install_package "zoxide" "zoxide" "zoxide"

# Install asdf (note: no need to install it at Arch, the package is always latest)
if [[ "$PKG_MANAGER" == "apt" ]]; then
  # For Ubuntu/Debian, install asdf via git
  ASDF_DIR="$HOME_DIR/.asdf"
  if [ ! -d "$ASDF_DIR" ]; then
    echo "📦 Installing asdf via git..."
    # Install dependencies
    sudo apt update -qq
    sudo apt install -y curl git
    git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch v0.14.0
    echo "✅ Installed asdf"
  else
    echo "✅ asdf already installed"
  fi
elif [[ "$PKG_MANAGER" == "brew" ]]; then
  install_package "asdf" "asdf" "asdf-vm"
fi

# Install oh my tmux if not already installed
echo ""
echo "⚙️ Setting up tmux configuration..."
if [ ! -f "$HOME_DIR/.config/tmux/tmux.conf.local" ]; then
  echo "📦 Installing oh my tmux..."
  curl -fsSL "https://github.com/gpakosz/.tmux/raw/refs/heads/master/install.sh#$(date +%s)" | bash
  echo "✅ Installed oh my tmux"
else
  echo "✅ oh my tmux already installed"
fi

# Set up asdf completions
echo ""
echo "🔧 Setting up asdf completions..."
ASDF_DATA_DIR="${ASDF_DATA_DIR:-$HOME_DIR/.asdfdir}"
mkdir -p "${ASDF_DATA_DIR}/completions"
ASDF_COMPLETION_FILE="${ASDF_DATA_DIR}/completions/_asdf"

if command -v asdf &> /dev/null; then
  if [ ! -f "$ASDF_COMPLETION_FILE" ]; then
    echo "📦 Setting up asdf zsh completion..."
    asdf completion zsh > "$ASDF_COMPLETION_FILE"
    echo "✅ asdf zsh completion set up"
  else
    echo "✅ asdf zsh completion already exists"
  fi
else
  echo "⚠️ asdf not found in PATH; skipping completion setup"
  echo "   You may need to source asdf in your shell first"
fi

echo ""
echo "🎉 Setup complete. You're all set!"
echo ""
echo "📝 Notes:"
echo "   - Restart your shell or run 'source ~/.zshrc' to apply changes"
if [[ "$PKG_MANAGER" == "apt" ]]; then
  echo "   - For asdf, add this to your .zshrc:"
  echo "     . \"\$HOME/.asdf/asdf.sh\""
fi
if is_wsl; then
  echo ""
  echo "🐧 WSL-specific notes:"
  echo "   - If you updated /etc/wsl.conf, restart WSL with: wsl.exe --shutdown"
  echo "   - To setup Windows Terminal settings, run setup-windows.bat as Administrator"
  echo ""
  echo "📂 Opening Windows Explorer to setup-windows.bat location..."
  # Get the Windows path to the current directory
  WINDOWS_PATH=$(wslpath -w "$(pwd)")
  
  # Open Explorer and select the batch file
  explorer.exe "$WINDOWS_PATH"
  
  echo "✅ Explorer opened. Right-click setup-windows.bat and select 'Run as administrator'"
fi
