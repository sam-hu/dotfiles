#!/bin/zsh

# homebrew
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed, skipping..."
fi

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh already installed, skipping..."
fi

# Powerlevel10k - https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#oh-my-zsh
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "Powerlevel10k already installed, skipping..."
fi

# enhancd
ENHANCD_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/enhancd"
if [ ! -d "$ENHANCD_DIR" ]; then
  echo "Installing enhancd..."
  git clone https://github.com/babarot/enhancd.git "$ENHANCD_DIR"
else
  echo "enhancd already installed, skipping..."
fi

# zsh-autosuggestions
AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$AUTOSUGGESTIONS_DIR" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
else
  echo "zsh-autosuggestions already installed, skipping..."
fi

# zsh-syntax-highlighting
SYNTAX_HIGHLIGHTING_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ ! -d "$SYNTAX_HIGHLIGHTING_DIR" ]; then
  echo "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HIGHLIGHTING_DIR"
else
  echo "zsh-syntax-highlighting already installed, skipping..."
fi

# Kiro CLI (fka Fig)
if ! command -v kiro-cli &> /dev/null; then
  echo "Installing Kiro CLI..."
  curl -fsSL https://cli.kiro.dev/install | bash
else
  echo "Kiro CLI already installed, skipping..."
fi

# Setup symlinks
echo ""
echo "Setting up dotfile symlinks..."
SCRIPT_DIR="$( cd "$( dirname "${(%):-%x}" )" && pwd )"
"$SCRIPT_DIR/symlink.sh"
