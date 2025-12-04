#!/bin/zsh
# Non-admin Homebrew install script for macOS 
# Author: Thomas Brown 12/4/2025
# Designed for Jamf Self Service deployment
# Installs Homebrew in the current user's home directory and configures environment

#fail if commands exit with non-zero status, if undefined variable is used, or if a command in a pipeline fails
set -euo pipefail 

echo "===== Starting Homebrew User-Local Install ====="

# Exit if run as root — we want user-local install
if [ "$EUID" -eq 0 ]; then
    echo "Do not run as root. This script installs Homebrew into the user's home directory."
    exit 1
fi

#define paths and variables
BREW_PREFIX="$HOME/homebrew" #Set Homebrew prefix inside user's home directory
BREW_BIN="$BREW_PREFIX/bin/brew" #validate existing homebrew binary 
ZPROFILE="$HOME/.zprofile" #User's zprofile path
ZSHRC="$HOME/.zshrc" #User's zshrc path
CASK_LINE='export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"' #Cask options line
SHELLENV_LINE='eval "$('"$BREW_PREFIX"'/bin/brew shellenv)"' #Shellenv line to add to shell profiles

# Create Homebrew and user/Applications directories if they don't exist
mkdir -p "$BREW_PREFIX"
mkdir -p "$HOME/Applications"

# Install Homebrew only if it isn't already installed
if [ ! -x "$BREW_BIN" ]; then
    echo "Downloading and installing Homebrew into $BREW_PREFIX ..."
    curl -fsSL https://github.com/Homebrew/brew/tarball/master \
        | tar xz --strip 1 -C "$BREW_PREFIX"
    echo "Homebrew extracted successfully."
else
    echo "Homebrew already present; skipping download."
fi

# Function to append a line to a file if not already present
safe_append() {
    local FILE="$1"
    local LINE="$2"

    # If file is not writable, skip
    if [ ! -w "$FILE" ]; then
        echo "Skipping $FILE (not writable)"
        return
    fi

    #check if exact line already exists in file. Fail silently if file doesn't exist
    if ! grep -Fxq "$LINE" "$FILE" 2>/dev/null; then
        echo "$LINE" >> "$FILE" #add line to file
        echo "Added to $FILE: $LINE"
    else
        echo "$FILE already contains: $LINE"
    fi
}

# Append Homebrew environment setup to shell profiles
safe_append "$ZPROFILE" "$SHELLENV_LINE"
safe_append "$ZSHRC" "$SHELLENV_LINE"

# Append Cask options to allow user-local app installation
safe_append "$ZPROFILE" "$CASK_LINE"
safe_append "$ZSHRC" "$CASK_LINE"

# Apply environment for current script session
eval "$("$BREW_BIN" shellenv)"

echo "===== Homebrew Installation Complete ====="
"$BREW_BIN" --version