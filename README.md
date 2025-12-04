# Non-Admin Homebrew Installer for macOS

This script installs Homebrew into a user's home directory, configures shell environment paths, and sets `HOMEBREW_CASK_OPTS` to install casks in `~/Applications`. It is safe to use in Jamf Self Service for scoped users.

## Usage

Run as the standard user:

```bash

zsh install_homebrew.sh

**Important:** Do not run as root — this is a user-local install.

## Features

- **Idempotent:** Safe to re-run without overwriting configuration.  
- **Shell support:** Works with both login (`.zprofile`) and interactive (`.zshrc`) shells.  
- **Cask configuration:** Installs casks to `~/Applications` without requiring admin permissions.
