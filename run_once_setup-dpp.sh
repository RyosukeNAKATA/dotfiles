#!/usr/bin/env bash
set -euo pipefail

DPP_BASE="$HOME/.cache/dpp/repos/github.com/Shougo"
DENOPS_BASE="$HOME/.cache/dpp/repos/github.com/vim-denops"

mkdir -p "$DPP_BASE"
mkdir -p "$DENOPS_BASE"

clone_if_not_exists() {
    local repo_url="$1"
    local dest_dir="$2"
    if [ ! -d "$dest_dir" ]; then
        echo "==> Cloning $repo_url to $dest_dir..."
        git clone "$repo_url" "$dest_dir"
    fi
}

clone_if_not_exists "https://github.com/Shougo/dpp.vim.git" "$DPP_BASE/dpp.vim"
clone_if_not_exists "https://github.com/Shougo/dpp-ext-installer.git" "$DPP_BASE/dpp-ext-installer"
clone_if_not_exists "https://github.com/Shougo/dpp-protocol-git.git" "$DPP_BASE/dpp-protocol-git"
clone_if_not_exists "https://github.com/Shougo/dpp-ext-lazy.git" "$DPP_BASE/dpp-ext-lazy"
clone_if_not_exists "https://github.com/Shougo/dpp-ext-toml.git" "$DPP_BASE/dpp-ext-toml"
clone_if_not_exists "https://github.com/vim-denops/denops.vim.git" "$DENOPS_BASE/denops.vim"
