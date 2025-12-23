#!/bin/zsh

# homebrew
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed, skipping..."
fi

# Homebrew formulas to install
FORMULAS=(
  gh
)

echo ""
for formula in "${FORMULAS[@]}"; do
  if ! brew list --formula | grep -q "^${formula}$"; then
    echo "Installing ${formula}..."
    brew install "$formula"
  else
    echo "${formula} already installed, skipping..."
  fi
done

# Homebrew casks to install
CASKS=(
  bettertouchtool
  google-chrome
  iterm2
  itsycal
  kiro-cli
  mactex
  pulsar
  raycast
  rectangle-pro
  slack
  spotify
  visual-studio-code
)

echo ""
for cask in "${CASKS[@]}"; do
  if ! brew list --cask | grep -q "^${cask}$"; then
    echo "Installing ${cask}..."
    brew install --cask "$cask"
  else
    echo "${cask} already installed, skipping..."
  fi
done

# GitHub CLI authentication
echo ""
if ! gh auth status &>/dev/null; then
  echo "Logging into GitHub CLI..."
  gh auth login
else
  echo "GitHub CLI already authenticated, skipping..."
fi
echo ""

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
  git clone https://github.com/sam-hu/enhancd.git "$ENHANCD_DIR"
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
# Clone https://github.com/sam-hu/fig-autocomplete and point dev mode to /build
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
