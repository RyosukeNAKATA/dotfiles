#!/bin/bash

ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.config/ ~/.config
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/.psqlrc ~/.psqlrc
ln -sf ~/dotfiles/.zfunc/ ~/.zfunc

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python -

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

curl https://get.volta.sh | bash

for i in $(cat brewlist.txt); do
    brew upgrade $i
done

for i in $(cat cargolist.txt); do
    cargo install $i
done

pyenv install 3.8.7

volta install node