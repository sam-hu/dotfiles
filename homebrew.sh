#!/bin/zsh

# Color codes for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "━━━ Homebrew ━━━"
if ! command -v brew &> /dev/null; then
  echo "  Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo -e "  ${GREEN}✓${NC} Homebrew"
fi

# Homebrew formulas to install
FORMULAS=(
  gh
)

echo ""
echo "━━━ CLI Tools ━━━"
for formula in "${FORMULAS[@]}"; do
  if ! brew list --formula | grep -q "^${formula}$"; then
    echo "  Installing ${formula}"
    brew install "$formula"
  else
    echo -e "  ${GREEN}✓${NC} ${formula}"
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
echo "━━━ Applications ━━━"
for cask in "${CASKS[@]}"; do
  if ! brew list --cask | grep -q "^${cask}$"; then
    echo "  Installing ${cask}"
    brew install --cask "$cask"
  else
    echo -e "  ${GREEN}✓${NC} ${cask}"
  fi
done
