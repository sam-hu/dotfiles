#!/bin/zsh

# Color codes for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# GitHub CLI authentication
echo ""
echo "━━━ GitHub CLI ━━━"
if ! gh auth status &>/dev/null; then
  echo "  Authenticating GitHub CLI"
  gh auth login
else
  echo -e "  ${GREEN}✓${NC} GitHub authenticated"
fi

echo ""
echo "━━━ Shell Configuration ━━━"

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "  Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo -e "  ${GREEN}✓${NC} oh-my-zsh"
fi

# Powerlevel10k - https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#oh-my-zsh
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "  Installing Powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo -e "  ${GREEN}✓${NC} Powerlevel10k"
fi

# enhancd
ENHANCD_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/enhancd"
if [ ! -d "$ENHANCD_DIR" ]; then
  echo "  Installing enhancd"
  git clone https://github.com/sam-hu/enhancd.git "$ENHANCD_DIR"
else
  echo -e "  ${GREEN}✓${NC} enhancd"
fi

# zsh-autosuggestions
AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$AUTOSUGGESTIONS_DIR" ]; then
  echo "  Installing zsh-autosuggestions"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGGESTIONS_DIR"
else
  echo -e "  ${GREEN}✓${NC} zsh-autosuggestions"
fi

# zsh-syntax-highlighting
SYNTAX_HIGHLIGHTING_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ ! -d "$SYNTAX_HIGHLIGHTING_DIR" ]; then
  echo "  Installing zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HIGHLIGHTING_DIR"
else
  echo -e "  ${GREEN}✓${NC} zsh-syntax-highlighting"
fi

# Kiro CLI (fka Fig)
# Clone https://github.com/sam-hu/fig-autocomplete and point dev mode to /build
if ! command -v kiro-cli &> /dev/null; then
  echo "  Installing Kiro CLI"
  curl -fsSL https://cli.kiro.dev/install | bash
else
  echo -e "  ${GREEN}✓${NC} Kiro CLI"
fi