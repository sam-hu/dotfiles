#!/bin/zsh

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${(%):-%x}" )" && pwd )"

"$SCRIPT_DIR/symlink.sh"
"$SCRIPT_DIR/homebrew.sh"
"$SCRIPT_DIR/clitools.sh"
