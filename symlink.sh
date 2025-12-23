#!/bin/zsh

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${(%):-%x}" )" && pwd )"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if any backups were created
BACKUPS_CREATED=false

echo "Setting up dotfiles from $DOTFILES_DIR"
echo ""

# Function to create symlink
create_symlink() {
  local source="$1"
  local target="$2"

  # If target already exists
  if [ -e "$target" ] || [ -L "$target" ]; then
    # If it's already a symlink pointing to the correct location
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
      echo -e "${GREEN}✓${NC} $target already linked correctly"
      return
    fi

    # Check if contents are identical before backing up
    contents_match=false

    if [ -d "$source" ] && [ -d "$target" ] && [ ! -L "$target" ]; then
      # Compare directories recursively (deep equality check)
      # This checks that both directories have the exact same files with
      # identical contents, recursively through all subdirectories
      if diff -rq "$source" "$target" &>/dev/null; then
        contents_match=true
      fi
    elif [ -f "$source" ] && [ -f "$target" ] && [ ! -L "$target" ]; then
      # Compare files
      if cmp -s "$source" "$target"; then
        contents_match=true
      fi
    fi

    if [ "$contents_match" = true ]; then
      # Contents are identical, just replace with symlink (no backup needed)
      echo -e "${GREEN}✓${NC} $target contents match, replacing with symlink"
      rm -rf "$target"
    else
      # Contents differ or target is a symlink to wrong location, back up first
      backup="$target.backup.$(date +%Y%m%d_%H%M%S)"
      echo -e "${YELLOW}⚠${NC}  Backing up existing $target to $backup"
      mv "$target" "$backup"
      BACKUPS_CREATED=true
    fi
  fi

  # Create the symlink
  ln -s "$source" "$target"
  echo -e "${GREEN}✓${NC} Linked $target -> $source"
}

# Loop through all files and directories in the dotfiles subdirectory
for item in "$DOTFILES_DIR"/*; do
  # Get just the filename without the path
  filename=$(basename "$item")

  # Create symlink with dot prefix in home directory
  create_symlink "$item" "$HOME/.$filename"
done

echo ""
echo -e "${GREEN}Done!${NC} Dotfiles symlinked successfully."
if [ "$BACKUPS_CREATED" = true ]; then
  echo "Any existing files have been backed up with .backup.* extension"
fi
