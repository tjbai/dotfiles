#!/bin/bash

rm -f .zshrc
rm -rf .config/zed .config/nvim .config/neovide .config/ghostty

cp ~/.zshrc .

mkdir -p .config/zed
cp -r ~/.config/zed/settings.json .config/zed/settings.json

mkdir -p .config/nvim
cp -r ~/.config/nvim/* .config/nvim/

mkdir -p .config/neovide
cp -r ~/.config/neovide/* .config/neovide/

mkdir -p .config/ghostty
cp -r ~/.config/ghostty/* .config/ghostty/

